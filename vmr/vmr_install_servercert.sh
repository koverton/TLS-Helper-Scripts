#!/bin/bash
#
# Copies the named cert file into the named container, 
# creates a CLI script in the container to enable the 
# server cert, and give you the command to run the script
# - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -

scriptdir=`dirname $0`

if [ "$#" -ne 2 ]; then
	echo "  USAGE: $0 <container> <cert>"
	echo ""
	exit 0
fi
container=$1
cert=$2

function msg() {
  line="- + - + - + - + - + - + - + - + - + - + - + - + -"
  echo ""; echo "$line"; echo "$*"; echo "$line"; echo ""
}

# Subject: C=US, ST=NY, L=NYC, O=Solace, OU=POC, CN=kovertonCA/emailAddress=ken.overt
cname=`openssl x509 -in $cert -text | grep 'Subject:' | sed 's/^.*CN=\(.*\)\/.*$/\1/g'`

msg Copying $cert into $container certs directory
docker cp $cert $container:/usr/sw/jail/certs/

# CLI cmds
#	enable
#	configure
#	ssl server-certificate $cert

# SEMPv1 equivalent
msg Creating a CLI script to be run on the server because SSL cannot be modified via SEMP until SEMP is enabled
cd $scriptdir
certfile=`basename $cert`
cat .install-server-cert.cli | sed s/__FILENAME__/$certfile/ > $certfile.cli
docker cp $certfile.cli $container:/usr/sw/jail/cliscripts/$certfile.cli
rm -f $certfile.cli

msg You must run CLI cmd: source script cliscripts/$certfile.cli stop-on-error no-prompt
