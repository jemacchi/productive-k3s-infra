# Cómo Usar Productive K3S Infra

`productive-k3s-infra` ahora se organiza alrededor de profiles como entrypoint público, mientras que las implementaciones completas siguen viviendo bajo `scenarios/`.

## Elegí el profile correcto

- `multipass-1-server-2-agents`: clúster local de tres nodos sobre VMs de Multipass
- `on-prem-basic` / `on-prem-arm`: bootstrap de hosts existentes por `SSH`
- `aws-single-node-basic`: provisioning de una instancia `EC2` con `OpenTofu` y bootstrap remoto

## Entendé el contrato de ejecución

Cada escenario se hace cargo de la infraestructura alrededor del clúster, mientras que `productive-k3s-core` sigue siendo responsable del bootstrap del clúster en sí.

En la práctica eso significa que `productive-k3s-infra` maneja:

- creación de hosts o selección de hosts existentes
- inventarios generados y metadata del clúster
- copia del bundle desde un checkout local o un release remoto
- orquestación de las fases `server`, `agent` y `stack` cuando el escenario lo necesita
- validación específica del escenario

## Engine opcional de instalación de K3S

El engine por default sigue siendo el camino nativo de bootstrap de Productive K3S.

Los usuarios avanzados también pueden optar por:

```bash
PRODUCTIVE_K3S_ENGINE=k3sup
```

Eso está documentado intencionalmente como experimental.

Por qué existe:

- para mostrar que `k3sup` puede complementar a `productive-k3s-core`
- para permitir que usuarios avanzados experimenten con las mismas decisiones opinionadas de plataforma de Productive K3S usando un backend de instalación de K3S que ya conocen

Qué no significa:

- `k3sup` no es el producto
- `k3sup` no reemplaza el contrato de bootstrap de Productive K3S
- `k3sup` no amplía la matriz pública de soporte más allá de la cobertura documentada de VMs, sistemas operativos y escenarios del repositorio

Si habilitás el engine experimental, seguís dentro del modelo de soporte de Productive K3S sólo en los lugares que la matriz y los tests del repositorio cubren de forma explícita.
Fuera de ese scope, especialmente en combinaciones custom o manualmente orquestadas, la responsabilidad pasa al usuario que está experimentando.

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

- comandos runtime basados en paquetes sobre `productive-k3s-infra.sh`
- resolución de paquetes desde herramientas de nivel superior como `pk3s`

Ejemplos de runtime público:

```bash
./productive-k3s-infra.sh profile validate --tgz ./multipass-1-server-2-agents.tgz
./productive-k3s-infra.sh profile install --tgz ./aws-single-node-basic.tgz --env-file ./aws.env
pk3s profile validate multipass-1-server-2-agents
pk3s infra install aws-single-node-basic --env-file ./aws.env
```

El `profile.env` embebido en un `profile.tgz` público se trata como archivo base/default del paquete, no como la configuración final específica de la instalación. `profile.yaml` declara metadata `spec.inputs` para que el runtime pueda forzar qué valores pueden salir de los defaults del paquete y cuáles deben venir desde la máquina que invoca. Usar un profile empaquetado sin overrides locales solo tiene sentido para targets autocontenidos, como escenarios locales guiados por el host. Para instalaciones reales, especialmente en cloud y on-prem, pasá overrides locales desde la máquina que invoca mediante `--env-file`.

## Usá los entrypoints de desarrollo

Los profiles `.env` siguen siendo válidos para desarrollo del repositorio, CI y workflows de authoring.

Ejemplos de desarrollo:

```bash
./productive-k3s-infra.sh dev profile validate --profile-env ./profiles/edge/on-prem/basic.env
./productive-k3s-infra.sh dev profile plan --profile-env ./profiles/local/multipass/1-server-2-agents.env
./productive-k3s-infra.sh dev profile apply --profile-env ./profiles/cloud/aws-single-node/basic.env
make infra-validate PROFILE=profiles/edge/on-prem/basic.env
make infra-plan PROFILE=profiles/local/multipass/1-server-2-agents.env
```

Usá `dev profile validate` cuando sólo quieras chequear que el contrato del `.env` sea válido. Usá `validate` del escenario o el target correspondiente de `make` cuando quieras la validación específica del escenario después del provisioning, que puede requerir estado generado como inventarios o metadata del clúster.

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
