#!/bin/bash
# 
# wrapper command to easily validate a server cert was signed 
# by the CA cert. Assumes your CA-cert is in ../ca/<caname>.pem
# - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -

cd `dirname $0`

if [ "$#" -ne 2 ]; then
	echo "  USAGE: $0 <caname> <cert>"
	echo ""
	exit 0
fi

# openssl verify -CAfile $1.pem $2
openssl verify -verbose -x509_strict -CAfile ../ca/$1.pem -CApath nosuchdir $2

