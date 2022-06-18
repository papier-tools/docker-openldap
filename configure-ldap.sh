export DOMAIN="dc=home"

echo "Installing packages..."
apk add openldap openldap-back-mdb openldap-clients

echo "Configuring for v2.3+ style slapd.d config directory..."
install -m 755 -o ldap -g ldap -d /etc/openldap/slapd.d
sed -i~ \
    -e 's/^cfgfile=/#cfgfile=/' \
    -e 's/^#cfgdir=.*/cfgdir=\"\/etc\/openldap\/slapd.d\"/' \
/etc/conf.d/slapd
rm /etc/openldap/slapd.conf

echo "Customizing for domain: ${DOMAIN}..."
sed -i~ \
    -e 's/\.la$/.so/' \
    -e "s/dc=my-domain,dc=com/${DOMAIN}/" /etc/openldap/slapd.ldif

echo "Adding schema for Linux user accounts..."
cp /etc/openldap/slapd.ldif /etc/openldap/slapd.ldif~1
awk '{ print } /^include:/ { sub("core", "cosine", $0); print $0; sub("cosine", "inetorgperson"); print $0; sub("inetorgperson", "nis"); print  }' /etc/openldap/slapd.ldif~1 >/etc/openldap/slapd.ldif

echo "Importing configuration..."
slapadd -n 0 -F /etc/openldap/slapd.d -l /etc/openldap/slapd.ldif
chown -R ldap:ldap /etc/openldap/slapd.d/*

echo "Configuring slapd service..."
install -m 755 -o ldap -g ldap -d /var/lib/openldap/run
service slapd start
rc-update add slapd
