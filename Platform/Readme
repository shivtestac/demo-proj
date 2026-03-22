#Repository Structure

```
infra/            → Terraform (AWS infrastructure)
k8s/              → Kubernetes manifests (deployment template + ingress)
observability/    → Monitoring / OpenTelemetry setup
```

---

# Admin Setup (Run Once)

The following components are **static resources** and must be created **only once by the platform/admin team**.

---

## 1. Infrastructure (`infra/`)

Creates:

* VPC
* EKS cluster
* IAM roles (per team)
* GitHub OIDC access

### Run

cd infra

terraform init

terraform apply -target=module.vpc -target=module.eks -auto-approve
terraform apply -auto-approve


## 2. Observability (`observability/`)

Deploy shared telemetry collector.

kubectl apply -f observability/collector.yaml


## 3. Ingress / Gateway (`k8s/ingress/`)
helm repo add traefik https://traefik.github.io/charts
helm repo update

helm upgrade --install traefik traefik/traefik \
  --namespace traefik-system \
  --create-namespace \
  -f values.yaml

### Apply Gateway

kubectl apply -f k8s/ingress/gateway.yaml

### Important

* This is a **shared gateway for all teams**
* Runs in namespace: `traefik-system`
* Uses **LoadBalancer with fixed IP**

 **Reserve the LoadBalancer IP in advance** to avoid changes







#  Application Deployment (For Teams)

Teams do NOT manage infrastructure or ingress.

They only:

* Write application code
* Call the shared pipeline

### Example (Team Repo)

name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    permissions:
      id-token: write
      contents: read
    uses: shivtestac/platform-pipelines/.github/workflows/deploy.yml@main
    with:
      team: Team-a
      app_name: app1

