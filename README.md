# Distributed Zero-Trust CI/CD & Software Supply-Chain Security Platform

DevSecOps platform that enforces security across build → sign → verify → deploy → runtime.

## Setup
1. Replace `ORG/REPO` in `policies/*.yaml`, `Jenkinsfile`, with your GitHub path.
2. Cluster: `kubectl apply -f https://github.com/kyverno/kyverno/releases/latest/download/install.yaml`
3. `kubectl apply -f k8s/namespace.yaml -f k8s/rbac.yaml -f k8s/networkpolicy.yaml -f policies/`
4. Vault: `./vault/setup.sh ORG/REPO`
5. GitHub secrets: `VAULT_ADDR`, `SLACK_WEBHOOK`; create environment `production` (add required reviewers).
6. Store the kubeconfig (for the `ci-deployer` SA) in Vault: `vault kv put kv/cicd/k8s kubeconfig=@kc.yaml`
7. Push to `main`.

## Security validation (compromised image)
```
./scripts/validate-compromised-image.sh
```
Proves the platform: **detects** vulnerabilities & secret → **generates SBOM** → **rejects artifact** → **blocks K8s deployment** → **records audit event** → **alerts admins**.
Via CI: run workflow manually with `image_dir=compromised-test`; the Trivy gate fails, nothing is pushed or signed, and `alert-on-failure` fires.

See `docs/ARCHITECTURE.md`.
