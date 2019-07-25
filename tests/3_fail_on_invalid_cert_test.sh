#!/bin/bash

vmr=192.168.56.101
vpn=poc_vpn
cert_keystore=invalid_certs.keystore

sdkperf_java.sh -cip=tcps://$vmr -cu=sslclient@$vpn -ptl=ssl/topic -mn=10000 -stl=ssl/topic -q -md \
	-sslts=`pwd`/$cert_keystore -sslvc
