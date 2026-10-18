#!/usr/bin/env bash
# Configure Vault for GitHub OIDC (JWT) auth: no long-lived credentials in CI. Needs VAULT_ADDR + admin token.
set -euo pipefail
ORG_REPO="${1:?usage: setup.sh org/repo}"
vault secrets enable -path=kv kv-v2 || true
vault policy write cicd vault/cicd-policy.hcl
vault auth enable jwt || true
vault write auth/jwt/config oidc_discovery_url="https://token.actions.githubusercontent.com" bound_issuer="https://token.actions.githubusercontent.com"
vault write auth/jwt/role/github-cicd -<<JSON
{
  "role_type":"jwt","user_claim":"actor","policies":["cicd"],
  "bound_audiences":["https://github.com/${ORG_REPO%%/*}"],
  "bound_claims_type":"glob",
  "bound_claims":{"repository":"${ORG_REPO}","ref":"refs/heads/main"},
  "ttl":"10m","max_ttl":"15m"
}
JSON
echo "Vault ready: tokens live 10 minutes, bound to ${ORG_REPO}@main."
