FROM debian:bullseye-slim

LABEL Maintainer="PapierPain <papierpain4287@outlook.fr>"
LABEL Description="OpenLDAPain container based on Debian Linux"

WORKDIR /openldap

####################
# INSTALLATION
####################
#

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y ldap-utils slapd && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

####################
# CONFIGURATION
####################
#

COPY *.sh /openldap/

RUN chmod +x /openldap/*.sh && rm -rf /etc/ldap/slapd.d/* /var/lib/ldap/*

EXPOSE 389 636

VOLUME ["/etc/ldap/slapd.d", "/var/lib/ldap", "/openldap/ldifs"]

ENTRYPOINT ["/openldap/run.sh"]
