# Architecture

```
Dev push ─► GitHub/GitLab ─► CI (GitHub Actions | Jenkins | GitLab CI)
   1 Secret scan (gitleaks)   2 SAST (Semgrep)   3 Dependency scan (Trivy fs)
   4 Build Docker  ─► 5 Trivy image scan (gate) ─► 6 SBOM (CycloneDX)
   7 Push by digest ─► 8 Cosign keyless sign (OIDC) + SBOM attestation
   9 DAST (OWASP ZAP baseline)
  10 Verify signature+attestation ─► Vault (JWT/OIDC, 10-min token) ─► kubectl apply
                                              │
                    Kubernetes: Kyverno admission re-verifies signature, SBOM, registry,
                    non-root, no :latest ─► RBAC + NetworkPolicy default-deny + PSA restricted
                                              │
            Audit: pipeline audit.log + kube-apiserver audit + Kyverno PolicyReports ─► alerts
```

## Zero-trust principles mapped
| Principle | Control |
|---|---|
| Never trust, always verify | Verification in CI *and* at the cluster admission layer |
| No static credentials | GitHub OIDC → Vault JWT role (10 min TTL), Cosign keyless |
| Least privilege | Namespaced Role for `ci-deployer`, SA token not auto-mounted |
| Assume breach | Default-deny NetworkPolicy, read-only rootfs, drop ALL caps |
| Provenance | Signed digests, SBOM attestation, `provenance: mode=max` |
| Auditability | `audit.sh` JSON log, K8s audit policy, Kyverno reports |

## Requirement coverage
GitHub/GitLab ✔ · Jenkins/GH Actions ✔ · Docker security ✔ · Trivy ✔ · SBOM ✔ · Dependency scan ✔ · Secret scan ✔ · SAST ✔ · DAST ✔ · Container signing ✔ · Artifact verification ✔ · Supply-chain policies ✔ · Admission controllers ✔ · K8s RBAC ✔ · Network policies ✔ · Vault ✔ · Short-lived credentials ✔ · OIDC ✔ · Zero-trust architecture ✔ · Audit logs ✔
