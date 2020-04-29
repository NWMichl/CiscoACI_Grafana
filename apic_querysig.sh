#!/bin/bash
#
# Invoke: sh apic_querysig <APIC-FQDN or IP> <API-Operation> <username> <private.key filename>
# Example: sh apic_querysig.sh sandboxapicdc.cisco.com /api/class/fabricHealthTotal.json telegraf telegraf.key
#

# Variable definition from bash arguments
apic=$1
operation=$2
username=$3
privatekeyfile=$4

# Generate X.509 Signature to sign the REST-Call
#
# echo -n => print out "GET"$operation without newline
# openssl dgst -sha256 -sign $privatekeyfile => generate a sha256 signature in binary format by using the X.509 private key
# openssl enc -A -base64 => convert binary format to base64 and eliminate newlines by using the -A option
#
sig="$(/bin/echo -n "GET"$operation | openssl dgst -sha256 -sign $privatekeyfile | openssl enc -A -base64)"

# Build http header cookie from various variables
#
# Cookie:
# APIC-Certificate-Algorithm=v1.0;
# APIC-Certificate-DN=uni/userext/user-$username/usercert-$username.crt; # Destinguished Name of the APIC mngt object where the user's public key is stored
# APIC-Certificate-Fingerprint=fingerprint;
# APIC-Request-Signature=$sig # Generated one step above
#
header="Cookie: APIC-Certificate-Algorithm=v1.0; APIC-Certificate-DN=uni/userext/user-$username/usercert-$username.crt; APIC-Certificate-Fingerprint=fingerprint; APIC-Request-Signature=$sig"

# APIC Query Operation
curl -s -k -X GET https://$apic$operation -H "$header"
