# Flujo De CI/CD

Este repositorio ya tiene un modelo de validación apto para CI aunque el árbol público actual no incluya todavía workflows de GitHub Actions.

## Qué existe hoy

- targets raíz determinísticos de `make` para docs y validación por matriz
- niveles estructurados `static`, `contract` y `live`
- artefactos JSON anónimos bajo `test-artifacts/` como evidencia de ejecución
- una separación clara entre entrypoints orientados al operador y scripts internos

## Modelo práctico de CI/CD

En CI, el flujo esperado es:

1. ejecutar `make test-static`
2. ejecutar `make test-contract`
3. ejecutar la capa live sólo donde el entorno lo permita
4. conservar los artefactos resultantes como evidencia

## Por qué documentarlo ahora

Aun sin workflows versionados, documentar el contrato de CI/CD importa porque:

- estabiliza la interfaz del repositorio
- define qué debería invocar la automatización futura
- mantiene alineadas la ejecución local y la ejecución en CI

## Notas

!!! note
    Esta página describe el modelo de ejecución actual del repositorio y la forma del CI/CD. No afirma que ya exista una implementación completa de GitHub Actions dentro del árbol público.
