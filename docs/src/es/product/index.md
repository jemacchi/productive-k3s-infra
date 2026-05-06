# Resumen Del Producto

`Productive K3S Infra` es el repositorio compañero de infraestructura para `Productive K3S`.

No reemplaza la lógica de bootstrap del clúster que vive en `productive-k3s`. En cambio, empaqueta las preocupaciones de infraestructura alrededor de ese bootstrap como casos de uso públicos y reutilizables:

- provisioning de máquinas cuando hace falta
- renderizado de inventarios y metadata generada
- orquestación por `SSH` y bootstrap
- supuestos de red entre nodos
- validación del entorno resultante

En las páginas siguientes podés ver para qué sirve este repositorio, cómo está pensado para usarse y dónde está hoy el límite entre lo público/open y lo Pro.

## Páginas

- [Cómo usar Productive K3S Infra](how-to-use.md)
- [Razones del diseño](reasons-behind.md)
- [Open vs Pro](open-vs-pro.md)
- [Relación con Productive K3S](productive-k3s-relationship.md)
