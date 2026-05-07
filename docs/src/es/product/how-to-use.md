# Cómo Usar Productive K3S Infra

`productive-k3s-infra` está organizado alrededor de casos de uso completos bajo `use-cases/`, no alrededor de snippets aislados.

## Elegí el caso de uso correcto

- `multipass`: clúster local de tres nodos sobre VMs de Multipass
- `onprem-basic`: bootstrap de hosts existentes por `SSH`
- `aws-single-node`: provisioning de una instancia `EC2` con `OpenTofu` y bootstrap remoto

## Entendé el contrato de ejecución

Cada caso de uso se hace cargo de la infraestructura alrededor del clúster, mientras que `productive-k3s` sigue siendo responsable del bootstrap del clúster en sí.

En la práctica eso significa que `productive-k3s-infra` maneja:

- creación de hosts o selección de hosts existentes
- inventarios generados y metadata del clúster
- copia del bundle desde un checkout local o un release remoto
- orquestación de las fases `server`, `agent` y `stack` cuando el caso de uso lo necesita
- validación específica del caso de uso

## Elegí el modo fuente de Productive K3S

La mayoría de los casos de uso públicos soportan dos modos fuente:

- `PRODUCTIVE_K3S_SOURCE=local`: empaqueta un checkout local hermano de `productive-k3s`
- `PRODUCTIVE_K3S_SOURCE=remote`: descarga un bundle desde un GitHub Release publicado

Si se usa `remote`, `PRODUCTIVE_K3S_VERSION` puede fijar una versión específica. Si se omite, el caso de uso resuelve el último release desde `PRODUCTIVE_K3S_RELEASE_REPO`.

## Usá los entrypoints públicos

La interfaz pública para operar el repo es:

- el CLI de release: `productive-k3s-infra-cli.sh`
- atajos locales de `make` en el root del repositorio
- comandos directos `make -C use-cases/...` cuando quieras trabajar explícitamente dentro de un caso de uso

Ejemplos con el CLI de release:

```bash
curl -fsSL https://github.com/<owner>/<repo>/releases/download/vX.Y.Z/productive-k3s-infra-cli.sh | bash -s -- multipass up
curl -fsSL https://github.com/<owner>/<repo>/releases/download/vX.Y.Z/productive-k3s-infra-cli.sh | bash -s -- onprem preflight
curl -fsSL https://github.com/<owner>/<repo>/releases/download/vX.Y.Z/productive-k3s-infra-cli.sh | bash -s -- aws-single-node validate
```

Atajos del Makefile root:

```bash
make multipass
make onprem
make aws-single-node
```

Patrones habituales de comandos por caso de uso:

- sólo infraestructura: `infra-up`
- sólo preflight: `preflight`
- bootstrap completo: `up`
- sólo validación: `validate`
- inspección del estado generado: `status`
- cleanup o teardown: `clean` o `down`

Ver [Targets de Make](../user-docs/make-targets.md) para el detalle completo.

## Notas

!!! note
    Estos casos de uso públicos son deliberadamente pragmáticos. Están pensados para poder evaluarse, reutilizarse y explicarse. No se presentan como blueprints completamente endurecidos para producción.

!!! note
    Los artefactos generados dentro de cada caso de uso forman parte del flujo público. Hacen más fácil inspeccionar decisiones de infraestructura, inputs de bootstrap y estado de validación.
