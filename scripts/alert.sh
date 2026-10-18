#!/usr/bin/env bash
# Alert security administrators (Slack webhook; falls back to stdout)
MSG="🚨 SECURITY ALERT: $1"
if [ -n "${SLACK_WEBHOOK:-}" ]; then
  curl -fsS -X POST -H 'Content-type: application/json' --data "{\"text\":\"$MSG\"}" "$SLACK_WEBHOOK"
else
  echo "$MSG"
fi
