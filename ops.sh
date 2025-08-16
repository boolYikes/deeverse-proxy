#!/bin/bash

PROJ_PATH="/lab/dee/repos_side/deeverse_proxy"
COMPOSE_DEFAULT="$PROJ_PATH/docker-compose-default.yaml"
COMPOSE_INIT="$PROJ_PATH/docker-compose-init.yaml"
RESULT_PATH="$PROJ_PATH/certbot/www/.result"

check_result() {
    local FILE="$1"
    local INTERVAL="${2:-5}"
    local ATTEMPTS="${3:-30}"
    
    local attempt=1
    while [ $attempt -le $ATTEMPTS ]; do
        if [ -f "$FILE" ]; then
            echo "Done!"
            return 0
        fi
        echo "Certbot is still working. Checkup in $INTERVAL secconds..."
        attempt=$((attempt+1))
        sleep "$INTERVAL"
    done

    echo "Timeout. File not found after $((INTERVAL * ATTEMPTS)) seconds"
    return 1
}

if [ $# -eq 0 ]; then
    echo "Usage: $0 [Flags]"
    echo "--run: Default run-checkcert-reload if needed"
    echo "--init: First run"
    echo "--down: Turn it off."
else
    for arg in "$@"; do
        case "$arg" in
            --run)
                echo "Running Nginx + cert check!"
                docker compose -f "$COMPOSE_DEFAULT" up -d
                if check_result "$RESULT_PATH" 5 30; then
                    docker compose -f "$COMPOSE_DEFAULT" exec nginx nginx -s reload -c /etc/nginx/conf.d/default.conf
                else
                    echo "Certbot did not run for some reason"
                    exit 1
                fi
                ;;
            --init)
                echo "Doing the first run shuffle..."
                docker compose -f "$COMPOSE_INIT" up -d
                if check_result "$RESULT_PATH" 5 30; then
                    docker compose -f "$COMPOSE_INIT" down && docker compose -f "$COMPOSE_DEFAULT" up -d
                else
                    echo "Certbot did not run for some reason"
                    exit 1
                fi
                ;;
            --down)
                echo "Turning off...?"
                docker compose -f "$COMPOSE_DEFAULT" down
                ;;
            *)
                echo "Usage: $0 [Flags]"
                echo "--run: Default run-checkcert-reload if needed"
                echo "--init: First run"
                echo "--down: Turn it off."
                exit 1
                ;;
        esac
    done
fi
