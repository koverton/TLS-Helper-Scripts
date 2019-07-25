#!/bin/bash
cd `dirname $0`/..

if [ "$#" -ne 2 ]; then
	echo "  USAGE: $0 <eventbroker> <vpnname>"
	echo ""
	exit 0
fi
vmr=$1
vpn=$2
topic=ssl/topic
name=demo

sdkperf_java.sh -cip=tcps://$vmr -cu=@$vpn \
	-ptl=$topic/$vmr -mn=10000 -mt=persistent \
	-stl=$topic/\> -q -md \
	-sslks=`pwd`/client/$name.keystore -sslksp=solace1 

#sdkperf_jms.sh -cip=tcps://$vmr -cu=@$vpn -jndi -jcf=/jms/cf/default -ptl=$topic -mn=10000 -stl=$topic -q -md \
#	-sslks=`pwd`/client/$name.keystore -sslksp=solace1 

