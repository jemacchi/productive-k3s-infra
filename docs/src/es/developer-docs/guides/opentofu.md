# Uso De OpenTofu

`OpenTofu` se usa en este repositorio para preocupaciones de provisioning de infraestructura, no para la lógica de bootstrap del clúster.

## Dónde se usa hoy

- `scenarios/local/multipass/opentofu/`: crea la topología local de VMs usada por el flujo de Multipass
- `scenarios/cloud/aws-single-node/opentofu/`: provisiona la infraestructura pública de AWS para el flujo single-node

## De qué se hace cargo OpenTofu

- creación de máquinas
- inputs de networking a nivel provider
- metadata y outputs de instancias
- valores que pasan a formar parte de `generated/cluster.json`

## De qué no se hace cargo acá

- orquestación del bootstrap por SSH
- secuenciación de modos de Productive K3S Core
- validación del stack final del clúster

Esas responsabilidades quedan en los scripts del escenario o en la capa remota compartida.

## Espacio de módulos a nivel repositorio

El directorio top-level `opentofu/modules/` está reservado para bloques reutilizables de infraestructura.

Las notas actuales del repositorio ya explicitan la distinción:

- la lógica pública reutilizable de bootstrap remoto ya existe bajo `ansible/roles/remote_cluster`
- los módulos reutilizables top-level de OpenTofu siguen siendo más un espacio a futuro que el principal camino de reutilización de los escenarios públicos implementados hoy

## Guía de desarrollo

Cuando edites un escenario respaldado por OpenTofu:

- mantené alineados los outputs con lo que esperan los scripts de refresh
- preservá la forma de la metadata generada usada por `status`, los tests y los scripts posteriores
- dejá la lógica específica del provider dentro del escenario salvo que claramente pertenezca a un módulo compartido
