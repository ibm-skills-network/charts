# Pontoon Helm Chart

## Prerequisites

- A valid domain name and TLS certificate (Optional, recommended for production deployment)
- An external managed PostgreSQL and RabbitMQ (Optional, recommended for production deployment)
- Kubernetes 1.12+
- Helm 3+

## Chart Details

This chart will do the following

- Deploy Pontoon server(s) and Celery worker deployment(s).
- Deploy a PostgreSQL database and a RabbitMQ instance **NOTE**: For production deployment it is recommended to use external managed services.

## Installing the Chart

### Add skills-network Helm Repository

```bash
helm repo add sn https://charts.skills.network
```

### Install Chart (Non-Production)

If you are looking to try out Pontoon in a non-production environment, such as, [kind](https://kind.sigs.k8s.io/), [minikube](https://minikube.sigs.k8s.io). Save [values-unsafe.yaml](./values-unsafe.yaml) locally.

```bash
helm install pontoon sn/pontoon --values ./values-unsafe.yaml
```

### Install Chart (Production-ish)

This will deploy both Pontoon server and a Celery worker instance, along with both Postgres and RabbitMQ. However, it's still not suitable for production-grade deployment. Save [values-demo.yaml](./values-demo.yaml) locally.

```bash
helm install pontoon sn/pontoon --values ./values-demo.yaml
```

### Install Chart (Production)

Create a value file with the configuration

`values-production.yaml`

```yml
siteUrl: "https://pontoon.example.com"

secretKey: "randomsecret"

extraEnvVars:
  - name: ALLOWED_HOSTS
    value: "pontoon.example.com"

postgres:
  enabled: false
  databaseUrl: postgres://username:password@postgres.host:5432/pontoon

rabbitmq:
  enabled: false
  url: amqps://username:password@rabbitmq.host:5672/pontoon

ingress:
  enabled: true
  annotations:
    external-dns.alpha.kubernetes.io/hostname: "pontoon.example.com"
    external-dns.alpha.kubernetes.io/target: "ingress.hostname"
    cert-manager.io/cluster-issuer: acme-issuer
    acme.cert-manager.io/http01-edit-in-place: "true"
  hosts:
    - "pontoon.example.com"
  tls:
  - hosts:
    - "pontoon.example.com"
    secretName: "tls-cert-secret"
```

```bash
helm install pontoon sn/pontoon --values ./values-production.yaml
```
