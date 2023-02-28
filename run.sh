#!/bin/bash

set -e

/openldap/init-openldap.sh
slapd -F /etc/ldap/slapd.d -h "ldap:/// ldaps:/// ldapi:///"
tail -f /dev/null
