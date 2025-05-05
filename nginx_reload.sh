#!/bin/bash

# It doesn't do a squat for now

source /etc/letsencrypt/.env

curl -X POST http://nginx:80/reload-nginx 

response=$(curl -s -w "%{http_code}" -o /dev/null \
    -X POST http://nginx/reload-nginx)

if [ "$response" = "200" ]; then
    echo "[SUCCESS] NGINX reload signal accepted (HTTP $response). Manually reload nginx!"
else
    echo "[ERROR] Reload signal failed (HTTP $response)" >&2
    exit 1
fi