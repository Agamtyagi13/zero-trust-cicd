#!/usr/bin/env bash
# Usage: verify-artifact.sh <image@digest> <org/repo>
set -euo pipefail
IMG="$1"; REPO="$2"
ID_RE="^https://github.com/${REPO}/.github/workflows/.*@refs/heads/main$"
ISS="https://token.actions.githubusercontent.com"
echo "[verify] signature"
cosign verify --certificate-identity-regexp "$ID_RE" --certificate-oidc-issuer "$ISS" "$IMG" >/dev/null
echo "[verify] SBOM attestation"
cosign verify-attestation --type cyclonedx --certificate-identity-regexp "$ID_RE" --certificate-oidc-issuer "$ISS" "$IMG" >/dev/null
echo "[verify] OK"
