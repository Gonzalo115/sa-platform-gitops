# SA Platform — repositorio GitOps público

Este repositorio representa el estado deseado de SA Platform para la Práctica 8. ArgoCD observa `environments/prod` y es el único componente autorizado para reconciliar cambios con GKE.

## Estructura

```text
charts/                         charts independientes por componente
environments/prod/              chart raíz observado por ArgoCD
  templates/analysis.yaml       smoke y k6 contra el candidato
  templates/policies.yaml       tres ClusterPolicies Kyverno
  templates/sealed-secrets...   secretos cifrados para el clúster
  values-prod.yaml              versiones productivas
  values-dev.yaml               valores de desarrollo
scripts/validate.sh             validación local del repositorio
```

## Flujo de cambios

1. La pipeline del repositorio de código publica imágenes firmadas.
2. La pipeline abre un Pull Request que modifica los tags de `values-prod.yaml`.
3. Un responsable revisa y combina el Pull Request.
4. ArgoCD detecta el nuevo commit.
5. Argo Rollouts ejecuta el canary y sus AnalysisRuns.

No agregue credenciales legibles. Los secretos reales deben generarse con `kubeseal` y quedar en `sealed-secrets.generated.yaml` como `encryptedData`.

## Validación

```bash
bash scripts/validate.sh
```

## Imágenes

Todas las imágenes usan versiones semánticas concretas. La etiqueta mutable `latest` está prohibida por política.

