# TLS Certificate Helper Scripts

These Linux scripts are what I came up with to quickly 
generate certificates for my Solace PubSub+ test cases. 
Not production calibre, internet-ready stuff, just certs 
you can use to reliably validate your security infrastructure 
and client code.

Created for use with Solace PubSub+ Event Brokers. For other 
servers, modifications are surely necessary.


# Certificate Authority Creation

`ca/ca_setup.sh <caname>`

## Outputs
```
ca/<caname>.pem # public CA certificate (minus private key)
ca/<caname>.key # private key, might be needed for future signing
ca/<caname>.keystore # truststore file for other apps to validate signed certs
```

This script generates a key and cert for use in signing 
other server certificates, and for installing on servers 
as a CA file to validate signed certificates. For example, 
if you want to have clients authenticate with their own 
cert, you'd like to test that your server properly validates 
their cert was signed by a known CA (yours).

## CA Installation on Solace Event Broker Container

`ca/vmr_install_ca.sh <container> <certfile>`

This script copies the certfile into the container's `certs` 
directory, then creates a CA entity within the broker to be 
used for validating certificates signed by that CA.


# Server Certificate Creation

`vmr/create_servercert.sh <caname> <servername>`

## Outputs
```
vmr/<servername>.pem  # server cert (public plus private key)
vmr/<servername>.key  # private key, might be needed for future use
vmr/<servername>.crt  # public cert (minus private key)
```

This script generates a full server certificate for installation 
in any server intended to support encrypted sessions via TLS.
Also produces private key and public cert files.

## Server Certificate Installation

`vmr/vmr_install_servercert.sh <container> <cert>`

Installs a server certificate in a Solace PubSub+ Event Broker 
docker container including the following steps:
1. copy the file into the container's `certs` directory;
2. create a CLI script to install/enable the cert in the Event Broker;
3. copy the CLI script into the container
4. **YOU MUST RUN THE RESULTING SCRIPT AT A CLI PROMPT YOURSELF**


# Client Certificate Creation

`client/create_clientcert.sh <caname> <cname>`

## Outputs
```
client/<cname>.crt
client/<cname>.key
client/<cname>.keystore
```

This script creates a simple client certificate for certificate 
authentication. It signs it with the CA-certificate expected 
to reside in `../ca/<caname>.pem`, and creates a Java truststore 
file with the full signing chain for use in client-auth testing 
and validation.


# Test Scripts

```
1_basic_tls_client_test.sh
2_validate_server_cert_test.sh
3_fail_on_invalid_cert_test.sh
4_client_cert_auth.sh
```

SDKPerf scripts to test TLS capabilities of Solace PubSub+ Event Brokers.
More details about each use-case can be found within each script.

