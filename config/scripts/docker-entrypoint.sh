#!/bin/bash

/opt/openldap/servers/slapd/slapd -d 5 -h 'ldap:/// ldapi:///' -f /etc/openldap/slapd.conf
