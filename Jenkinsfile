pipeline {
  agent any
  environment { IMAGE = "ghcr.io/ORG/REPO/secure-app"; TAG = "${env.GIT_COMMIT}" }
  stages {
    stage('Secrets')  { steps { sh 'docker run --rm -v $PWD:/repo zricethezav/gitleaks:latest detect -s /repo --exit-code 1' } }
    stage('SAST')     { steps { sh 'docker run --rm -v $PWD:/src semgrep/semgrep semgrep scan --config auto --error /src' } }
    stage('Build')    { steps { sh 'docker build -t $IMAGE:$TAG app' } }
    stage('Trivy')    { steps { sh 'trivy image --severity HIGH,CRITICAL --exit-code 1 $IMAGE:$TAG' } }
    stage('SBOM')     { steps { sh 'trivy image --format cyclonedx -o sbom.cdx.json $IMAGE:$TAG' } }
    stage('Push+Sign'){ steps { withCredentials([string(credentialsId:'cosign-oidc', variable:'X')]) {
        sh 'docker push $IMAGE:$TAG && cosign sign --yes $IMAGE:$TAG && cosign attest --yes --type cyclonedx --predicate sbom.cdx.json $IMAGE:$TAG' } } }
    stage('DAST')     { steps { sh 'docker run -d -p 8080:8080 --name app $IMAGE:$TAG && docker run --rm --network host ghcr.io/zaproxy/zaproxy:stable zap-baseline.py -t http://localhost:8080' } }
    stage('Deploy')   { steps { sh './scripts/verify-artifact.sh $IMAGE:$TAG ORG/REPO && kubectl apply -f k8s/' } }
  }
  post { failure { sh './scripts/audit.sh PIPELINE_REJECTED "$BUILD_URL"; ./scripts/alert.sh "Jenkins build rejected: $BUILD_URL"' } }
}
