# OpenLDAP module

```bash
mkdir /etc/ldap/conf
cd /etc/ldap/conf/
mkdir memberof
cd memberof/

mkdir memberof-module.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f memberof-module.ldif
# Check configuration
ldapsearch -LLL -Y EXTERNAL -H ldapi:/// -b  cn=config -LLL | grep -i module
ldapsearch -LLL -Y EXTERNAL -H ldapi:/// -b  cn=config olcDatabase | grep mdb


mkdir memberof-add-conf.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f memberof-add-conf.ldif
# Check configuration
ldapsearch -LLL -Y EXTERNAL -H ldapi:/// -b  cn=config olcDatabase | grep mdb


mkdir refint-module.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f refint-module.ldif
# Check configuration
ldapsearch -H ldapi:/// -Y EXTERNAL -LLL -b "dc=papierpain,dc=fr" cn=admin
ldapsearch -H ldapi:/// -Y EXTERNAL -LLL -b "dc=papierpain,dc=fr" memberOf

ldapdelete -x -w Des_p@lme12Hier -D "cn=admin,dc=papierpain,dc=fr" cn=admin,ou=groups,dc=papierpain,dc=fr
ldapsearch -H ldapi:/// -Y EXTERNAL -LLL -b "dc=papierpain,dc=fr" memberOf

ldapadd -x -w Des_p@lme12Hier -D "cn=admin,dc=papierpain,dc=fr" -f admin-group.ldif
ldapsearch -H ldapi:/// -Y EXTERNAL -LLL -b "dc=papierpain,dc=fr" memberOf
```