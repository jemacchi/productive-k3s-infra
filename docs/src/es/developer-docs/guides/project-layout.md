# Organización Del Proyecto

El repositorio está organizado alrededor de casos de uso públicos más capas compartidas de infraestructura.

## Estructura de alto nivel

```text
productive-k3s-infra/
  use-cases/
    multipass/
    onprem-basic/
    aws-single-node/
  ansible/
    roles/
      remote_cluster/
  opentofu/
    modules/
  tests/
  docs/
```

## División de responsabilidades

- `use-cases/`: entrypoints públicos y flujos orientados a operadores
- `ansible/roles/remote_cluster`: assets compartidos para bootstrap remoto y validación
- `opentofu/`: bloques reutilizables de infraestructura y espacio de módulos a futuro
- `tests/`: entrypoints de validación static, contract y live
- `docs/`: sitio bilingüe de documentación

## Artefactos generados

Cada caso de uso escribe metadata generada bajo su propio directorio `generated/`, normalmente incluyendo:

- `cluster.json`
- `hosts.yml`
- `server-token.txt`
- logs u outputs específicos del provider cuando corresponde

Estos artefactos son parte del flujo porque exponen la vista resuelta en runtime del caso de uso.

## Notas

!!! note
    El repositorio está centrado intencionalmente en `use-cases/`, no en helpers de bajo nivel. Los usuarios públicos deberían arrancar por un camino de despliegue, no por un detalle interno de implementación.
