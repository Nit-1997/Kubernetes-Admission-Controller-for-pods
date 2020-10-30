cat <<EOF | cfssl genkey - | cfssljson -bare server
{
"hosts": [
"admission-webhook.kso-control.svc",
"admission-webhook.kso-control.svc.cluster.local"
],
"CN": "admission-webhook.kso-control.svc",
"key": {
"algo": "ecdsa",
"size": 256
}
}
EOF

