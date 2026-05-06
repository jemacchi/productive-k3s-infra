# Caso De Uso Multipass

`multipass` es el camino preferido para validación local de un entorno multinodo de Productive K3S.

## Qué construye

- `1` VM servidor
- `2` VMs agentes
- `stack` compartido instalado en el servidor después de armar el clúster

## Comandos principales

```bash
make -C use-cases/multipass infra-up
make -C use-cases/multipass cluster-up
make -C use-cases/multipass up
make -C use-cases/multipass validate
make -C use-cases/multipass status
make -C use-cases/multipass down
make -C use-cases/multipass clean
```

## Qué hace `make up`

1. Lanza las tres VMs con `OpenTofu` y Multipass.
2. Renderiza metadata generada a partir de las IPs reales de las VMs.
3. Prepara un bundle de `productive-k3s` desde fuente `local` o `remote`.
4. Ejecuta el modo `server` en el primer nodo.
5. Captura el token de join del servidor.
6. Ejecuta el modo `agent` en los nodos restantes.
7. Sincroniza aliases de Rancher y registry dentro de las VMs.
8. Ejecuta el modo `stack` sobre el servidor.
9. Valida readiness de nodos, namespaces core, reachability de ingress y defaults de storage.

## Notas

!!! note
    Este caso de uso no actualiza hoy `/etc/hosts` en la máquina de control. Los hostnames de Rancher y registry quedan garantizados dentro de las VMs, no automáticamente en el host.

!!! note
    Una primera instalación de `Rancher` sobre un clúster frío puede pasar varios minutos en `ContainerCreating` mientras se descargan imágenes.

!!! note
    Es el mejor camino público cuando querés ejercitar localmente el modelo separado de `server` y `agent`.
