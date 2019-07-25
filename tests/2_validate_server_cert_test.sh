#!/bin/bash
cd `dirname $0`/..

vmr=localhost
vpn=default
user=demo
cert_keystore=`pwd`/ca/kovertonCA.keystore

sdkperf_java.sh -cip=tcps://$vmr -cu=$user@$vpn -ptl=ssl/topic -mn=10000 -stl=ssl/topic -q -md \
	-sslts=$cert_keystore -sslvc
