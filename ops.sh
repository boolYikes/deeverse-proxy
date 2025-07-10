#!/bin/bash

COMPOSE="/lab/dee/repos_side/deeverse_proxy/docker-compose.yaml"

if [ $# -eq 0 ]; then
    echo "Run without args for this man page."
    echo "--ng: Only run nginx."
    echo "--cert: Run certbot and then nginx."
    echo "--cert-only: Run certbot and terminate."
    echo "--down: Turn it off."
else
    for arg in "$@"; do
        case "$arg" in
            --ng)
                echo "Running Nginx straight up!"
                docker compose -f "$COMPOSE" up nginx -d
                ;;
            --cert)
                echo "Gotta check dem certs. No sweat!"
                docker compose -f "$COMPOSE" up certbot -d
                docker compose -f "$COMPOSE" up nginx -d
                ;;
            --cert-only)
                echo "Renewal only and then terminating..."
                docker compose -f "$COMPOSE" up certbot -d
                docker compose -f "$COMPOSE" down certbot
                ;;
            --down)
                echo "We have rights to deny services...I think...?"
                docker compose -f "$COMPOSE" down
                ;;
            *)
                echo "Unknown argument: $arg" >&2
                exit 1
                ;;
        esac
    done
fi
