

export DOMAIN=demodomain21.com

curl -HHost:${DOMAIN} localhost 

curl localhost
curl localhost/healthz
curl localhost/test


# Test mtls with the client cert should see the teapot
curl -v -HHost:${DOMAIN} --resolve ${DOMAIN}:$SECURE_INGRESS_PORT:$INGRESS_HOST \
--cacert 2_intermediate/certs/ca-chain.cert.pem \
--cert 4_client/certs/${DOMAIN}.cert.pem \
--key 4_client/private/${DOMAIN}.key.pem \
https://${DOMAIN}:$SECURE_INGRESS_PORT/status/418

# Send header
Refer to: https://stackoverflow.com/questions/356705/how-to-send-a-header-using-a-http-request-through-a-curl-call

curl -i -H "Accept: application/json" -H "Content-Type: application/json" http://hostname/resource
curl -H "Accept: application/xml" -H "Content-Type: application/xml" -X GET http://hostname/resource
