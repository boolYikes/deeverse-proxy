#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Run without args for this man page."
    echo "--ng: Only run nginx."
    echo "--cert: Run certbot and then nginx."
    echo "--cert-only: Run certbot and terminate."
else
    for arg in "$@"; do
        case "$arg" in
            --ng)
                echo "Running Nginx straight up!"
                docker compose up nginx -d
                ;;
            --cert)
                echo "Gotta check dem certs. No sweat!"
                docker compose up certbot -d
                docker compose up nginx -d
                ;;
            --cert-only)
                echo "Renewal only and then terminating..."
                docker compose up certbot -d
                docker compose down
                ;;
            --down)
                echo "We have rights to deny services...I think...?"
                docker compose down
                ;;
            *)
                echo "Unknown argument: $arg" >&2
                exit 1
                ;;
        esac
    done
fi