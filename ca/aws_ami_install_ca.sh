#!/bin/bash
#
# Copies the named CA file into the Solace PubSub+ Event Broker AMI on aws, 
# and creates CA on the Event Broker via SEMP.
# ASSUMES the remotehost is an instance of an Solace PubSub+ AMI (either enterprise or standard)
# and the SEMP UI is accessible via port 8080.
# - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -
#
# CLI cmds
#	enable
#	configure
#	authentication
#	create certificate-authority $cname
#	certificate file $cert
cd `dirname $0`

if [ "$#" -ne 4 ]; then
	echo "  USAGE: $0 <remote-host-address> <aws-ssh-identity-certificate> <ca-certificate-file> <admin-password>"
	echo ""
	exit 0
fi
host=$1
idfile=$2
cert=$3
pass=$4
vmr=$host

function msg() {
  line="- + - + - + - + - + - + - + - + - + - + - + - + -"
  echo ""; echo "$line"; echo "$*"; echo "$line"; echo ""
}
msg Copying $cert up to $host 
scp -i $idfile $cert sysadmin@$vmr:

msg Copying $cert into $container certs directory
container=`ssh -i $idfile sysadmin@$vmr docker ps | grep 'solace-pubsub' | awk 'NF>1{print $NF}'`
certfile=`basename $cert`
ssh -i $idfile sysadmin@$vmr docker cp $certfile $container:/usr/sw/jail/certs/


msg Extracting CAName from $certfile CNAME
cname=`openssl x509 -in $certfile -text | grep 'Subject:' | sed 's/^.*CN=\(.*\)\/.*$/\1/g'`

msg Creating $cname on $vmr via SEMP command
cat .create-ca.xml | sed "s/__CANAME__/$cname/" > tmp.xml
curl -X POST -u admin:$pass http://$vmr:8080/SEMP -d @tmp.xml
rm -f tmp.xml


msg Setting CA $cname certificate filename to $certfile via SEMP command
filename=`basename $certfile`
cat .set-ca-file.xml | sed "s/__CANAME__/$cname/" | sed "s/__FILENAME__/$filename/" > tmp.xml
curl -X POST -u admin:$pass http://$vmr:8080/SEMP -d @tmp.xml
rm -f tmp.xml
