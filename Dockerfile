FROM alpine:latest

# We build a standalone linux binary, see Makefile target buildonly
COPY ./bin/AdmissionWebhook /go/bin/AdmissionWebhook

# Run the binary.

ENTRYPOINT ["/go/bin/AdmissionWebhook"]