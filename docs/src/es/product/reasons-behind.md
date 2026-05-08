# Razones Del Diseño De `productive-k3s-infra`

`productive-k3s-infra` existe porque `productive-k3s` y la orquestación de infraestructura resuelven problemas distintos.

## Por qué no alcanza con `productive-k3s`

`productive-k3s` es el contrato de bootstrap para instalar y validar un stack basado en K3S.

Eso alcanza cuando:

- ya existe un host
- el operador puede trabajar directamente sobre esa máquina
- la topología del clúster es lo bastante simple como para armarla a mano

No alcanza cuando además necesitás estandarizar:

- cómo se provisionan las máquinas
- cómo se declaran los roles de nodos
- cómo se renderizan inventarios y hostnames
- cómo se secuencian los pasos de bootstrap multinodo
- cómo debería correrse una validación específica de infraestructura

## Por qué los escenarios son el entrypoint público

Este repositorio está centrado intencionalmente en `scenarios/` en lugar de snippets genéricos.

El objetivo de diseño es ofrecer caminos de despliegue que sean:

- reutilizables
- evaluables
- explícitos
- cercanos a lo que un equipo realmente ejecutaría

Por eso los entrypoints públicos son cosas como:

- clústeres locales con Multipass
- bootstrap on-premises por SSH
- un camino básico single-node sobre AWS

y no una colección de helpers desconectados.

## Por qué mantener capas compartidas por debajo

Aun cuando la interfaz pública está orientada a escenarios, la implementación igual necesita fronteras de reutilización.

Por eso el repositorio mantiene lógica compartida en capas como:

- `ansible/roles/remote_cluster` para bootstrap y validación del lado SSH
- `opentofu/` para concerns de provisioning
- `tests/` para validación static, contract y live

Esa separación hace más fácil evolucionar un camino público sin copiar y pegar todo en cada uno de los demás.

## Por qué importa la separación explícita por modos

Los modos `server`, `agent`, `stack` y `single-node` expuestos por `productive-k3s` son lo que vuelve realista la orquestación de infraestructura.

Le permiten a este repositorio:

1. crear o apuntar máquinas primero
2. ensamblar el clúster después
3. instalar el stack compartido al final

Sin esa separación, la automatización de infraestructura tendría que pelear contra un bootstrap más monolítico.

## Racional general

Tomado como conjunto, el repositorio busca ubicarse entre scripting crudo de infraestructura y una plataforma privada totalmente productizada.

Apunta a ofrecer:

- flujos de infraestructura que sigan siendo públicos y entendibles
- escenarios más realistas que ejemplos de juguete
- un puente estable hacia entornos K3S reales, remotos o multinodo

## Ver también

- [Resumen del producto](index.md)
- [Cómo usar Productive K3S Infra](how-to-use.md)
- [Relación con Productive K3S](productive-k3s-relationship.md)
