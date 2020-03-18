#!/bin/bash
# 
# Creates a new server-certificate for a VMR and signs 
# it with the signing cert from your CA.
# - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -
cd `dirname $0`

if [ "$#" -ne 2 ]; then
	echo "  USAGE: $0 <caname> <routername>"
	echo ""
	exit 0
fi
caname=$1
name=$2
# caname=kovertonCA
# name=laptop
fqdn=$name.poc.solace.com

function msg() {
  line="- + - + - + - + - + - + - + - + - + - + - + - + -"
  echo ""; echo "$line"; echo "$*"; echo "$line"; echo ""
}


msg Create the private key
openssl genrsa -out $name.key 2048
chmod 600 $name.key

msg Generate the cert signing request
openssl req -new -key $name.key -out $name.csr
  # Country Name (2 letter code) []:US
  # State or Province Name (full name) []:NY
  # Locality Name (eg, city) []:NYC
  # Organization Name (eg, company) []:Solace
  # Organizational Unit Name (eg, section) []:POC
  # Common Name (eg, fully qualified host name) []:laptop
  # Email Address []:ken.overton@solace.com
cat << 'EOF' >> $name.ext
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
EOF
echo "DNS.1 = $name" >> $name.ext # variables aren't expanded in cat
echo "DNS.2 = $fqdn" >> $name.ext # variables aren't expanded in cat

msg Creating the certificate by signing it
openssl x509 -req \
  -in $name.csr \
  -CA ../ca/$caname.pem -CAkey ../ca/$caname.key -CAcreateserial \
  -out $name.crt -days 824 -sha256 -extfile $name.ext
cat $name.key > $name.pem; cat $name.crt >> $name.pem

msg Your public-cert is $name.crt and server cert is $name.pem

# CLEANUP: we really dont need CSR files sitting around
rm -f $name.csr $name.ext
