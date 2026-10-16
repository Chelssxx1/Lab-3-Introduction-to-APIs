#!/usr/bin/env bash

set -euo pipefail 
IFS=$'\n\t'

log() {
    echo "$1" >> "$LOG_FILE"
    }

cleanup() {
    log "LAB3_END"
}
trap cleanup EXIT

#VARIABLES
JOKE_URL="https://icanhazdadjoke.com/"
DECK_URL="https://deckofcardsapi.com/api/deck"
DATA_DIR="data"
LOG_FILE="logs/lab3.log"

command -v curl
command -v jq 
log "BASH_OK"


joke_status=$(curl -sS -H 'Accept: application/json' -w '%{http_code}' -o "$DATA_DIR/dad_joke.json" "$JOKE_URL")

if [[ "$joke_status" != "200" ]]; then
    log "CURL_JOKE_FAIL"
    exit 1
fi

log "CURL_JOKE_OK"

jq -r '.id, .joke' "$DATA_DIR/dad_joke.json" > "$DATA_DIR/dad_joke.txt"
log "JQ_JOKE_OK"

deck_status=$(curl -sS -H 'Accept: application/json' -w '%{http_code}' -o "$DATA_DIR/deck_create.json" "$DECK_URL/new/shuffle/?deck_count=1")

if [[ "$deck_status" != "200" ]]; then
log "DECK_CREATE_FAIL"
exit 1
fi

log "DECK_CREATE_OK"

deck_id=$(jq -r '.deck_id' "$DATA_DIR/deck_create.json")

draw_status=$(curl -sS -H 'Accept: application/json' -w '%{http_code}' -o "$DATA_DIR/deck_draw.json" "$DECK_URL/$deck_id/draw/?count=2")

if [[ "$draw_status" != "200" ]]; then 
log "DECK_DRAW-FAIL"
exit 1
fi

log "DECK_DRAW_OK"

jq -r '.cards[] | "\(.value) of \(.suit)"' "$DATA_DIR/deck_draw.json" > "$DATA_DIR/deck_summary.txt" 
jq -r '"Remaining: \(.remaining)"' "$DATA_DIR/deck_draw.json" >> "$DATA_DIR/deck_summary.txt"

log "JQ_DECK_OK"

