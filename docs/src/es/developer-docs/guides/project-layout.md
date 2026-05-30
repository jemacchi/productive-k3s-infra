# Organización Del Proyecto

El repositorio está organizado alrededor de profiles versionados como entrypoint público de configuración, más implementaciones de escenarios y capas compartidas de infraestructura.

## Estructura de alto nivel

```text
productive-k3s-infra/
  profiles/
    cloud/
    edge/
    local/
  scenarios/
    cloud/
      aws-single-node/
    edge/
      onprem-basic/
      onprem-basic-arm/
    local/
      multipass/
  ansible/
    roles/
      remote_cluster/
  opentofu/
    modules/
  tests/
  docs/
```

## División de responsabilidades

- `profiles/`: ejemplos versionados de configuración pública para el CLI orientado a profiles
- `scenarios/`: implementaciones de escenarios y flujos orientados a operadores
- `ansible/roles/remote_cluster`: assets compartidos para bootstrap remoto y validación
- `opentofu/`: bloques reutilizables de infraestructura y espacio de módulos a futuro
- `tests/`: entrypoints de validación static, contract y live
- `docs/`: sitio bilingüe de documentación

## Artefactos generados

Cada escenario escribe metadata generada bajo su propio directorio `generated/`, normalmente incluyendo:

- `cluster.json`
- `hosts.yml`
- `server-token.txt`
- logs u outputs específicos del provider cuando corresponde

Estos artefactos son parte del flujo porque exponen la vista resuelta en runtime del escenario.

## Notas

!!! note
    Los usuarios públicos deberían arrancar hoy desde `profiles/` y el CLI orientado a profiles. `scenarios/` queda como la capa de implementación detrás de esos entrypoints.

!!! note
    Los paths canónicos ahora están orientados por categoría, por ejemplo `profiles/cloud/...` o `scenarios/edge/...`. Los paths legacy de nivel superior siguen disponibles como aliases de compatibilidad.
