#!/bin/bash
if [ "$#" -ne 1 ]; then
	echo "  USAGE: $0 <cert>"
	echo ""
	exit 0
fi

openssl x509 -in $1 -text

