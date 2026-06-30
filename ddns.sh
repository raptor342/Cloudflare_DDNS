#!/bin/sh

set -e

: "${CF_API_TOKEN:?Missing CF_API_TOKEN}"
: "${ZONE_ID:?Missing ZONE_ID}"
: "${RECORDS:?Missing RECORDS}"

TTL=${TTL:-120}
PROXIED=${PROXIED:-true}
INTERVAL=${INTERVAL:-300}
API="https://api.cloudflare.com/client/v4"

log() {
  echo "[$(date -Iseconds)] $*"
}

get_public_ip() {
  curl -fsS https://api.ipify.org
}

# 🔥 get record id by name
get_record_id() {
  NAME="$1"

  curl -fsS -X GET \
    "$API/zones/$ZONE_ID/dns_records?type=A&name=$NAME" \
    -H "Authorization: Bearer $CF_API_TOKEN" \
    -H "Content-Type: application/json" \
  | sed -n 's/.*"id":"\([^"]*\)".*/\1/p' | head -n1
}

get_cf_ip() {
  ID="$1"

  curl -fsS -X GET \
    "$API/zones/$ZONE_ID/dns_records/$ID" \
    -H "Authorization: Bearer $CF_API_TOKEN" \
    -H "Content-Type: application/json" \
  | sed -n 's/.*"content":"\([^"]*\)".*/\1/p'
}

update_record() {
  ID="$1"
  NAME="$2"
  IP="$3"

  log "Updating $NAME -> $IP"

  RESPONSE=$(curl -fsS -X PUT \
    "$API/zones/$ZONE_ID/dns_records/$ID" \
    -H "Authorization: Bearer $CF_API_TOKEN" \
    -H "Content-Type: application/json" \
    --data "{
      \"type\": \"A\",
      \"name\": \"$NAME\",
      \"content\": \"$IP\",
      \"ttl\": $TTL,
      \"proxied\": $PROXIED
    }")

  echo "$RESPONSE" | grep -q '"success":true' \
    && log "$NAME OK" \
    || log "$NAME FAILED: $RESPONSE"
}

log "DDNS started (auto-record lookup)"
log "Interval: ${INTERVAL}s"

while true; do
  IP=$(get_public_ip)

  if [ -z "$IP" ]; then
    log "ERROR: cannot fetch public IP"
    sleep "$INTERVAL"
    continue
  fi

  log "Current IP: $IP"

  echo "$RECORDS" | tr ',' '\n' | while read -r NAME; do

    [ -z "$NAME" ] && continue

    ID=$(get_record_id "$NAME")

    if [ -z "$ID" ]; then
      log "ERROR: record not found for $NAME"
      continue
    fi

    CF_IP=$(get_cf_ip "$ID")

    log "$NAME -> Cloudflare: $CF_IP"

    if [ "$IP" != "$CF_IP" ]; then
      update_record "$ID" "$NAME" "$IP"
    else
      log "$NAME no change"
    fi

  done

  sleep "$INTERVAL"
done