# Privacidad Y Telemetría

`productive-k3s-infra` produce manifests anónimos de ejecución para las corridas de matriz.

## Objetivos

- mantener estructurada y compartible la evidencia de regresión local y de CI
- hacer auditable en un repositorio público el comportamiento futuro de telemetría
- evitar incluir identificadores específicos del entorno en artefactos orientados a telemetría

## Artefactos anónimos de test

Las ejecuciones de matriz escriben artefactos JSON bajo `test-artifacts/`.

Están pensados para capturar:

- nombre del escenario
- nivel de test
- resultado
- duración
- tipo de entorno
- topología esperada
- modos de bootstrap ejercitados

No están pensados para capturar:

- direcciones IP
- hostnames
- usernames
- paths locales del filesystem
- identificadores de cuentas cloud
- targets SSH

## Reglas de resolución

- si `TELEMETRY_ENABLED` se define explícitamente como `true` o `false`, se usa ese valor tal cual
- si `TELEMETRY_ENABLED` no está definido y la corrida es interactiva, el repositorio pregunta una vez y el default es `Yes`
- si `TELEMETRY_ENABLED` no está definido y la corrida es no interactiva, resuelve a `false`
- los valores definidos en la matriz raíz se propagan hacia cada escenario
- cada escenario propaga esos mismos valores hacia los comandos nested de bootstrap de `productive-k3s-core`

## Variables soportadas para propagación

- `TELEMETRY_ENABLED`
- `TELEMETRY_ENDPOINT`
- `TELEMETRY_MAX_RETRIES`
- `TELEMETRY_CONNECT_TIMEOUT_SECONDS`
- `TELEMETRY_REQUEST_TIMEOUT_SECONDS`
- `TELEMETRY_OUTBOX_DIR`
- `TELEMETRY_USER_AGENT`

## Notas

!!! note
    Los artefactos de infraestructura permanecen anónimos por defecto. Un manifest compartible puede registrar que la telemetría estaba habilitada, pero no debería exponer valores de endpoint.

!!! note
    En este repositorio la telemetría forma parte de un contrato explícito con el operador, no de un efecto secundario oculto.
