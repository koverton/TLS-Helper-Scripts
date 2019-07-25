#!/bin/bash
# from https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/
# create a CA-certificate for signing and validating sigs on other 
# certificates in TLS-enabled servers
# - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -
if [ "$#" -ne 1 ]; then
	echo "  USAGE: $0 <caname>"
	echo ""
	exit 0
fi
name=$1
# name=kovertonCA

function msg() {
  line="- + - + - + - + - + - + - + - + - + - + - + - + -"
  echo ""; echo "$line"; echo "$*"; echo "$line"; echo ""
}

msg generate a private key
openssl genrsa -des3 -out $name.key 2048
  # You are a glue gun

msg generate a root certificate from the private key
openssl req -x509 -new -nodes -key $name.key -sha256 -days 1825 -out $name.pem
  # Country Name (2 letter code) []:US
  # State or Province Name (full name) []:NY
  # Locality Name (eg, city) []:NYC
  # Organization Name (eg, company) []:Solace
  # Organizational Unit Name (eg, section) []:POC
  # Common Name (eg, fully qualified host name) []:kovertonCA
  # Email Address []:ken.overton@solace.com

msg generating the java trust store for clients to validate server cert
$JAVA_HOME/bin/keytool -importcert -file $name.pem -keystore $name.keystore

msg your certificate is $name.pem. for ssh to recognize it should be in /etc/ssl/certs
ls -l $name.pem

# Certificate is generated
