#!/bin/bash

vmr=localhost
vpn=default
user=demo

sdkperf_java.sh -cip=tcps://$vmr -cu=$user@$vpn -ptl=ssl/topic -mn=10000 -stl=ssl/topic -q -md
