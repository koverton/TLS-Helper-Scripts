#!/bin/bash
#
# Copies the named CA file into the named container, 
# and creates CA on the Event Broker via SEMP
# ASSUMES the docker container is localhost, and exports 
# SEMP UI via port 8080.
# - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -
#
# CLI cmds
#	enable
#	configure
#	authentication
#	create certificate-authority $cname
#	certificate file $cert
cd `dirname $0`

if [ "$#" -ne 2 ]; then
	echo "  USAGE: $0 <container> <cert>"
	echo ""
	exit 0
fi
container=$1
cert=$2
vmr=localhost

function msg() {
  line="- + - + - + - + - + - + - + - + - + - + - + - + -"
  echo ""; echo "$line"; echo "$*"; echo "$line"; echo ""
}

msg Copying $cert into $container certs directory
certfile=`basename $cert`
docker cp $certfile $container:/usr/sw/jail/certs/


msg Extracting CAName from $certfile CNAME
cname=`openssl x509 -in $certfile -text | grep 'Subject:' | sed 's/^.*CN *= *//' | sed 's/,.*//'`

msg Creating $cname on $vmr via SEMP command
cat .create-ca.xml | sed "s/__CANAME__/$cname/" > tmp.xml
curl -X POST -u admin:admin http://$vmr:8080/SEMP -d @tmp.xml
rm -f tmp.xml


msg Setting CA $cname certificate filename to $certfile via SEMP command
filename=`basename $certfile`
cat .set-ca-file.xml | sed "s/__CANAME__/$cname/" | sed "s/__FILENAME__/$filename/" > tmp.xml
curl -X POST -u admin:admin http://$vmr:8080/SEMP -d @tmp.xml
rm -f tmp.xml
