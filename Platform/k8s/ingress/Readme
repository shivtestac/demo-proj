# Traefik Ingress Controller Setup

This directory contains the Helm deployment for the **Traefik Ingress Controller** on Kubernetes.  

---

## Prerequisites

- Kubernetes cluster (EKS, GKE, or self-managed) is up and running.
- Helm >= 3 installed.
- A **pre-reserved static IP** for the LoadBalancer if you want a fixed external IP.

> **Note:** Traefik service type is `LoadBalancer`. To avoid dynamic IP assignment, pre-allocate an IP and set it in `values.yaml` under `service.spec.loadBalancerIP`.

---

## Add Helm Repository

Add the official Traefik Helm repository:

```bash
helm repo add traefik https://traefik.github.io/charts
helm repo update




helm upgrade --install traefik traefik/traefik \
  --namespace traefik-system \
  --create-namespace \
  -f values.yaml



DNS Entry
root domain xyz.com 

team-a.xyz.com --------->    LB IP
team-b.xyz.com --------->    LB IP
.
.
.
team-z.xyz.com --------->   LB IP









i not mention TLS here but we can use certmanger etc..........
