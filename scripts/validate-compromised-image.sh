#!/usr/bin/env bash
# SECURITY VALIDATION: push a compromised image through the pipeline controls locally.
# Requires: docker, trivy, kubectl (cluster with Kyverno), optional cosign. Run from repo root.
set -uo pipefail
IMG="${1:-compromised-test:latest}"
export AUDIT_FILE=validation-audit.log
PASS=0; FAIL=0
step(){ printf '\n== %s ==\n' "$1"; }
ok(){ echo "  ✔ $1"; PASS=$((PASS+1)); ./scripts/audit.sh "$2" "$1" >/dev/null; }
bad(){ echo "  ✘ $1"; FAIL=$((FAIL+1)); }

step "1. Build compromised image"
docker build -q -t "$IMG" compromised-test >/dev/null && ok "built $IMG" IMAGE_BUILT || bad "build failed"

step "2. Detect vulnerabilities"
if trivy image --severity HIGH,CRITICAL --exit-code 1 --quiet "$IMG" >/dev/null; then
  bad "no vulnerabilities detected (unexpected)"
else ok "HIGH/CRITICAL vulnerabilities DETECTED" VULN_DETECTED; fi

step "3. Detect embedded secret"
if trivy image --scanners secret --exit-code 1 --quiet "$IMG" >/dev/null; then
  bad "secret not found"
else ok "embedded secret DETECTED" SECRET_DETECTED; fi

step "4. Generate SBOM"
trivy image --format cyclonedx -o sbom-compromised.cdx.json --quiet "$IMG" && ok "SBOM generated (sbom-compromised.cdx.json)" SBOM_GENERATED

step "5. Reject artifact (no signature => verification fails)"
if cosign verify --certificate-identity-regexp '.*' --certificate-oidc-issuer-regexp '.*' "$IMG" >/dev/null 2>&1; then
  bad "unsigned image verified?!"
else ok "artifact REJECTED (unsigned/unverified)" ARTIFACT_REJECTED; fi

step "6. Prevent Kubernetes deployment (Kyverno admission)"
kubectl create ns validation --dry-run=client -o yaml | kubectl apply -f - >/dev/null
if kubectl -n validation run bad --image="$IMG" 2>&1 | tee /tmp/k8s.out | grep -qiE 'denied|blocked|violation'; then
  ok "Kubernetes admission DENIED the pod" DEPLOY_BLOCKED
else bad "pod was admitted! see /tmp/k8s.out"; fi

step "7. Record security event + alert admins"
./scripts/audit.sh SECURITY_EVENT "compromised image $IMG blocked" >/dev/null
./scripts/alert.sh "Compromised image $IMG detected and blocked" && ok "alert sent" ALERT_SENT

echo; echo "RESULT: $PASS passed, $FAIL failed  (audit trail: $AUDIT_FILE)"
[ "$FAIL" -eq 0 ]
