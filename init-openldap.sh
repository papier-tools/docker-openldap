#!/usr/bin/env bash

set -e

# Set default values
: ${LDAP_ROOT:=dc=example,dc=fr}
: ${LDAP_ADMIN_USERNAME:=admin}
: ${LDAP_ADMIN_PASSWORD:=root}
: ${LDAP_CUSTOM_DB_DIR:=/var/lib/ldap}

LDAP_ADMIN_DN="cn=${LDAP_ADMIN_USERNAME},${LDAP_ROOT}"

# If the database already exists, do nothing
if [ -d "$LDAP_CUSTOM_DB_DIR" ]; then
    echo "Database already exists, skipping initialization"
    exit 0
fi

# Create new database
slapadd -n 0 -F /etc/ldap/slapd.d <<EOF
dn: cn=config
objectClass: olcGlobal
cn: config
olcArgsFile: /var/run/slapd/slapd.args
olcPidFile: /var/run/slapd/slapd.pid
olcToolThreads: 1
olcLogLevel: stats

dn: cn=module{0},cn=config
objectClass: olcModuleList
cn: module{0}
olcModulePath: /usr/lib/ldap
olcModuleLoad: {0}back_mdb
olcModuleLoad: {1}ppolicy
olcModuleLoad: {2}memberof
olcModuleLoad: {3}refint

dn: cn=schema,cn=config
objectClass: olcSchemaConfig
cn: schema

include: file:///etc/ldap/schema/core.ldif
include: file:///etc/ldap/schema/cosine.ldif
include: file:///etc/ldap/schema/nis.ldif
include: file:///etc/ldap/schema/inetorgperson.ldif
include: file:///etc/ldap/schema/ppolicy.ldif

dn: olcBackend={0}mdb,cn=config
objectClass: olcBackendConfig
olcBackend: {0}mdb

dn: olcDatabase={-1}frontend,cn=config
objectClass: olcDatabaseConfig
objectClass: olcFrontendConfig
olcDatabase: {-1}frontend
olcAccess: {0}to * by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=extern
 al,cn=auth manage by * break
olcAccess: {1}to dn.exact="" by * read
olcAccess: {2}to dn.base="cn=Subschema" by * read
olcSizeLimit: 500

dn: olcDatabase={0}config,cn=config
objectClass: olcDatabaseConfig
olcDatabase: {0}config
olcAccess: {0}to * by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=extern
 al,cn=auth manage by * break
olcRootDN: cn=admin,cn=config

dn: olcDatabase={1}mdb,cn=config
objectClass: olcDatabaseConfig
objectClass: olcMdbConfig
olcDatabase: {1}mdb
olcDbDirectory: $LDAP_CUSTOM_DB_DIR
olcSuffix: $LDAP_ROOT
olcAccess: {0}to attrs=userPassword by self write by anonymous auth by * non
 e
olcAccess: {1}to attrs=shadowLastChange by self write by * read
olcAccess: {2}to * by * read
olcLastMod: TRUE
olcRootDN: $LDAP_ADMIN_DN
olcRootPW: $(slappasswd -s $LDAP_ADMIN_PASSWORD)
olcDbCheckpoint: 512 30
olcDbIndex: objectClass eq
olcDbIndex: cn,uid eq
olcDbIndex: uidNumber,gidNumber eq
olcDbIndex: member,memberUid eq
olcDbMaxSize: 1073741824

dn: olcOverlay={0}ppolicy,olcDatabase={1}mdb,cn=config
objectClass: olcPPolicyConfig
olcOverlay: {0}ppolicy
olcPPolicyDefault: cn=ppolicy,$LDAP_ROOT
olcPPolicyHashCleartext: TRUE
olcPPolicyUseLockout: FALSE

dn: olcOverlay={1}memberof,olcDatabase={1}mdb,cn=config
objectClass: olcMemberOf
objectClass: olcOverlayConfig
objectClass: olcConfig
objectClass: top
olcOverlay: {1}memberof
olcMemberOfDangling: ignore
olcMemberOfRefInt: TRUE
olcMemberOfGroupOC: groupOfNames
olcMemberOfMemberAD: member
olcMemberOfMemberOfAD: memberOf
EOF
