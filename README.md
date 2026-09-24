# SA Platform GitOps — P9

Repositorio declarativo observado por ArgoCD. P9 agrega un patrón App-of-Apps y recuperación
ante desastres sin eliminar las capacidades de P8.

## Estructura

- `bootstrap/`: genera nueve aplicaciones hijas de ArgoCD.
- `platform/foundation/`: RBAC, cuotas, ClusterSecretStore y ExternalSecrets.
- `platform/data/`: PostgreSQL 16, seis bases lógicas y PVC de 10 GiB.
- `platform/backup/`: Schedule Velero cada 15 minutos con retención de siete días.
- `charts/`: charts de microservicios y Kafka de P8.
- `environments/prod/`: umbrella chart productivo, Rollouts, análisis, políticas e Ingress.

No se versionan secretos en claro ni SealedSecrets ligados a una clave privada de un clúster
anterior. Las credenciales se conservan en Google Secret Manager y External Secrets las
sincroniza.

## Validación

```bash
bash scripts/validate.sh
```

La aplicación raíz recibe desde Terraform el Project ID, zona, bucket Velero y las cuentas
de servicio de Workload Identity. Por ello no es necesario editar secretos o manifiestos
durante una reconstrucción.
