#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# CREATE THE PRIVATE KEY FOR OUR CUSTOM CA
openssl genrsa -out certs/ca.key 2048

# GENERATE A CA CERT WITH THE PRIVATE KEY
openssl req -new -x509 -key certs/ca.key -out certs/ca.crt

# CREATE THE PRIVATE KEY FOR OUR NITIN SERVER
openssl genrsa -out certs/nitin-key.pem 2048

# CREATE A CSR FROM THE CONFIGURATION FILE AND OUR PRIVATE KEY
openssl req -new -key certs/nitin-key.pem -subj "/CN=admission-webhook.kso-control.svc" -out nitin.csr

# CREATE THE CERT SIGNING THE CSR WITH THE CA CREATED BEFORE
openssl x509 -req -in nitin.csr -CA certs/ca.crt -CAkey certs/ca.key -CAcreateserial -out certs/nitin-crt.pem

# GET CA AND PASTE IN WEBHOOK CONFIG
cat certs/ca.crt | base64

#GENERATE OPENSHIFT SECRET
oc create secret generic admission-webhook -n kso-control \
  --from-file=key.pem=certs/nitin-key.pem \
  --from-file=cert.pem=certs/nitin-crt.pem
