#!/bin/bash

set -e

/openldap/init-openldap.sh
echo "Initialization : Done"
slapd -F /etc/ldap/slapd.d -h "ldap:/// ldaps:/// ldapi:///"
echo "Slapd started"
tail -f /dev/null
