# Tests Y Matriz

El repositorio expone un modelo de validación en tres niveles.

## Niveles de la matriz raíz

- `static`: sintaxis de shell, compilación de Python, validación de OpenTofu y ciertos tests de comportamiento
- `contract`: verifica que cada caso de uso público exponga los archivos, outputs, ignores y targets esperados
- `live`: ejecuta el flujo real del entorno cuando el ambiente lo permite

## Comandos raíz

```bash
make test-static
make test-contract
make test-live
make test-matrix
```

## Entry points principales de tests

- `tests/run-matrix.sh`
- `tests/contract-check.sh`
- `tests/live-multipass.sh`
- `tests/live-onprem-basic.sh`
- scripts de regresión específicos de telemetría bajo `tests/`

## Modelo de artefactos

Las corridas de matriz escriben manifests JSON bajo `test-artifacts/`.

Esos artefactos registran:

- caso de uso
- nivel
- resultado
- duración
- topología y clase de entorno
- detalles seleccionados de la fuente de Productive K3S
- metadata anónima relacionada con telemetría

## Guía de desarrollo

Cuando cambies un caso de uso público, revisá si tenés que actualizar:

- el target `test-static` local del caso de uso
- las expectativas de contrato en `tests/contract-check.sh`
- algún test de propagación de telemetría
- el contrato de metadata generada consumido por los manifests de matriz

## Notas

!!! note
    `aws-single-node` saltea intencionalmente el test público `live` salvo que existan credenciales y una cuenta de AWS disponibles. Ese comportamiento de skip forma parte del contrato público actual.
