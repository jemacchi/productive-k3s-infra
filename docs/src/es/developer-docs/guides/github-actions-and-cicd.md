# Flujo De CI/CD

Este repositorio tiene un modelo de validación apto para CI y ahora incluye un workflow público de GitHub Actions post-merge para el camino `onprem-basic` sobre un runner hospedado Ubuntu `24.04`.

## Qué existe hoy

- targets raíz determinísticos de `make` para docs y validación por matriz
- niveles estructurados `static`, `contract` y `live`
- artefactos JSON anónimos bajo `test-artifacts/` como evidencia de ejecución
- una separación clara entre entrypoints orientados al operador y scripts internos
- un target dedicado `test-live-gha-onprem` que trata al runner de GitHub como host remoto para `onprem-basic`
- un workflow de release por tags para `productive-k3s-infra-cli.sh`

## Tags de release

Los releases publicados deben usar tags compuestos:

- `X.Y.Z-A.B.C`
- `X.Y.Z`: versión de `productive-k3s-infra`
- `A.B.C`: release atado de `productive-k3s`

El workflow de release valida ese formato y publica un bundle de infra cuyo CLI público ya queda ligado a esa versión de `productive-k3s`.

## Modelo práctico de CI/CD

En CI, el flujo esperado es:

1. ejecutar `make test-static`
2. ejecutar `make test-contract`
3. ejecutar `make test-live-gha-onprem` después de merges a `main`
4. ejecutar la capa live más amplia sólo donde el entorno lo permita
5. conservar los artefactos resultantes como evidencia

## Por qué documentarlo ahora

Aun con workflow versionado, documentar el contrato de CI/CD importa porque:

- estabiliza la interfaz del repositorio
- define qué debería invocar la automatización futura
- mantiene alineadas la ejecución local y la ejecución en CI

## Workflow público actual

El repositorio incluye `.github/workflows/post-merge-onprem-github-host.yml`.

Ese workflow corre cuando un pull request apuntando a `main` se cierra en estado merged. Hace lo siguiente:

1. ejecuta `make test-static`
2. ejecuta `make test-contract`
3. hace checkout del repo hermano `productive-k3s`
4. ejecuta `make test-live-gha-onprem`

El job live prepara `openssh-server` sobre el runner hospedado por GitHub y luego ejercita `scenarios/onprem-basic` contra `127.0.0.1` como host remoto single-node.

Cuando la revisión checkout del repo hermano `productive-k3s` ya incluye `scripts/preflight-host.sh`, ese mismo camino hosted también ejercita el host preflight remoto de Productive K3S antes de que empiece el bootstrap.

## Notas

!!! note
    El workflow público valida a propósito sólo el camino single-host de `onprem-basic`. No reemplaza la matriz `live` más amplia, que todavía depende de entornos como Multipass o credenciales externas de cloud.
