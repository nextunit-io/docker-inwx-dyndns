#/bin/bash

#!/bin/bash
#
# Update host at inwx.de
#

# Checkups
command -v nslookup >/dev/null 2>&1 || { echo >&2 "nslookup is required and need to installed. Note: all needed items are listed in the README.md file."; exit 1; }

if [ -z "$INWX_USER" ] || [ -z "$INWX_PASSWORD" ] || [ -z "$INWX_DOMAIN_ID" ] || [ -z "$DYNDNS_DOMAIN" ] || [ -z "$API_ENDPOINT" ]; then
    echo >&2 "Please set all environment variables. Take a look into the README.md to see all variables."
    exit 1
fi

# Functions


_echo () {
    echo $*
}

_updateNsEntry() {
	local CURRENT_IP=$1
	local API_XML="<?xml version=\"1.0\"?><methodCall><methodName>nameserver.updateRecord</methodName><params><param><value><struct><member><name>user</name><value><string>$INWX_USER</string></value></member><member><name>pass</name><value><string>$INWX_PASSWORD</string></value></member><member><name>id</name><value><int>$INWX_DOMAIN_ID</int></value></member><member><name>content</name><value><string>$CURRENT_IP</string></value></member></struct></value></param></params></methodCall>"
	_echo "API-XML:"
	_echo $API_XML

    curl -v -X POST -H "Content-Type: application/xml" -d "$API_XML" $API_ENDPOINT

    if [ -n "$SLACK_DEBUG" ]; then
        curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"[DYNDNS-HOME]: Update home dns to '${CURRENT_IP}'. \"}" $SLACK_DEBUG
    fi
}

CURRENT_DIR=`dirname $0`
_echo $CURRENT_DIR

# Getting current ip
WAN_IP=`curl -s https://ip.dblx.io`;
_echo "Current IP is $WAN_IP"

NSLOOKUP_IP=`nslookup $DYNDNS_DOMAIN ns.inwx.de | tail -2 | tail -1 | awk '{print $2}'`;
_echo "IP of domain $DYNDNS_DOMAIN is $NSLOOKUP_IP"

if [ ! $NSLOOKUP_IP = $WAN_IP ]; then
	_echo "UPDATE NS-Entry."
	_updateNsEntry $WAN_IP
	echo -n `date +"%d.%m.%Y %T"`
	echo -n ": UPDATE NS-Entry to $WAN_IP - Old was: $NSLOOKUP_IP"
	echo ""
else
	_echo "No update needed. IP is the same."
fi