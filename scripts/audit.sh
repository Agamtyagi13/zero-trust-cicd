#!/usr/bin/env bash
# Append-only structured audit log: audit.sh EVENT "details"
printf '{"ts":"%s","event":"%s","details":"%s","host":"%s"}\n' \
  "$(date -u +%FT%TZ)" "$1" "$2" "$(hostname)" | tee -a "${AUDIT_FILE:-audit.log}"
