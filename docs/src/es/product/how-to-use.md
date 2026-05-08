# Cómo Usar Productive K3S Infra

`productive-k3s-infra` ahora se organiza alrededor de profiles como entrypoint público, mientras que las implementaciones completas siguen viviendo bajo `scenarios/`.

## Elegí el profile correcto

- `profiles/multipass/...`: clúster local de tres nodos sobre VMs de Multipass
- `profiles/on-prem/...`: bootstrap de hosts existentes por `SSH`
- `profiles/aws-single-node/...`: provisioning de una instancia `EC2` con `OpenTofu` y bootstrap remoto

## Entendé el contrato de ejecución

Cada escenario se hace cargo de la infraestructura alrededor del clúster, mientras que `productive-k3s-core` sigue siendo responsable del bootstrap del clúster en sí.

En la práctica eso significa que `productive-k3s-infra` maneja:

- creación de hosts o selección de hosts existentes
- inventarios generados y metadata del clúster
- copia del bundle desde un checkout local o un release remoto
- orquestación de las fases `server`, `agent` y `stack` cuando el escenario lo necesita
- validación específica del escenario

## Elegí el modo fuente de Productive K3S Core

La mayoría de los escenarios públicos soportan dos modos fuente:

- `PRODUCTIVE_K3S_SOURCE=local`: empaqueta un checkout local hermano de `productive-k3s-core`
- `PRODUCTIVE_K3S_SOURCE=remote`: descarga un bundle desde un GitHub Release publicado

Si se usa `remote`, `PRODUCTIVE_K3S_VERSION` puede fijar una versión específica. Si se omite, el escenario resuelve el último release desde `PRODUCTIVE_K3S_RELEASE_REPO`.

Cuando usás el `productive-k3s-infra-cli.sh` publicado desde un GitHub Release, ese release ya viene atado a una versión concreta de `productive-k3s-core`. En ese camino, el CLI fuerza:

- `PRODUCTIVE_K3S_SOURCE=remote`
- `PRODUCTIVE_K3S_VERSION=A.B.C`

El segmento `A.B.C` sale del tag de release de infra `X.Y.Z-A.B.C`.

## Usá los entrypoints públicos

La interfaz pública para operar el repo es:

- el CLI de release: `productive-k3s-infra-cli.sh`
- atajos locales `make infra-*` en el root del repositorio
- comandos directos `make -C scenarios/...` cuando quieras trabajar explícitamente dentro de un escenario

Ejemplos con el CLI de release:

```bash
curl -fsSL https://github.com/<owner>/<repo>/releases/download/X.Y.Z-A.B.C/productive-k3s-infra-cli.sh | bash -s -- validate --profile ./profiles/on-prem/basic.env
curl -fsSL https://github.com/<owner>/<repo>/releases/download/X.Y.Z-A.B.C/productive-k3s-infra-cli.sh | bash -s -- plan --profile ./profiles/multipass/1-server-2-agents.env
curl -fsSL https://github.com/<owner>/<repo>/releases/download/X.Y.Z-A.B.C/productive-k3s-infra-cli.sh | bash -s -- apply --profile ./profiles/aws-single-node/basic.env
```

Atajos del Makefile root:

```bash
make infra-list-profiles
make infra-validate PROFILE=profiles/on-prem/basic.env
make infra-plan PROFILE=profiles/multipass/1-server-2-agents.env
make infra-apply PROFILE=profiles/aws-single-node/basic.env
```

Patrones habituales de comandos por escenario:

- sólo infraestructura: `infra-up`
- sólo preflight: `preflight`
- bootstrap completo: `up`
- sólo validación: `validate`
- inspección del estado generado: `status`
- cleanup o teardown: `clean` o `down`

Ver [Targets de Make](../user-docs/make-targets.md) para el detalle completo.

## Notas

!!! note
    Estos escenarios públicos son deliberadamente pragmáticos. Están pensados para poder evaluarse, reutilizarse y explicarse. No se presentan como blueprints completamente endurecidos para producción.

!!! note
    Los artefactos generados dentro de cada escenario forman parte del flujo público. Hacen más fácil inspeccionar decisiones de infraestructura, inputs de bootstrap y estado de validación.
