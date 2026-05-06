# Open Vs Pro

Este repositorio es la base pública/open. Debería maximizar reutilización, evaluabilidad y claridad.

## Alcance público

El repositorio público es el lugar para:

- entornos locales basados en Multipass
- provisioning básico de nodo único sobre AWS
- bootstrap básico on-premises por `SSH`
- bloques genéricos en `OpenTofu`
- lógica genérica de bootstrap remoto con `Ansible` y shell
- contratos de tests, orquestación de matriz y artefactos anónimos de ejecución
- documentación que explique cómo funcionan los caminos públicos

## Alcance Pro o privado

Las extensiones comerciales o privadas pueden vivir por encima de esta base cuando requieren más comportamiento específico de cliente, por ejemplo:

- clústeres cloud en HA
- topologías privadas y networking endurecido
- inventarios administrados y composiciones por tenant
- upgrades automatizados y rollback
- workflows de backup y restore
- packs más ricos de validación y stacks de aplicaciones empaquetadas

## Por qué conviene explicitar el límite

El repositorio open debería seguir siendo entendible y ampliamente reutilizable.

Eso implica que el código público debería preferir:

- supuestos genéricos
- inputs de operador documentados
- entrypoints explícitos de `Makefile`
- capas reutilizables que no dependan de un entorno de cliente particular

## Notas

!!! note
    "Pro" es un límite de alcance, no una señal de que el repositorio open esté incompleto. El repositorio open igual debería ofrecer casos de uso reales y funcionando.

!!! note
    Los casos de uso públicos son intencionalmente simples en varios puntos. Esa simplicidad suele ser parte del posicionamiento del producto open, no necesariamente una feature faltante.
