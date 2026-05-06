# Caso De Uso On-Prem Basic

`onprem-basic` hace bootstrap de `productive-k3s` sobre máquinas que ya existen y son alcanzables por `SSH`.

## Qué espera

- una IP declarada como `server`
- cero o más IPs declaradas como `agent`
- un usuario remoto alcanzable
- `sudo` sin contraseña
- un runtime Ubuntu o Debian soportado

## Comandos principales

```bash
make -C use-cases/onprem-basic preflight
make -C use-cases/onprem-basic up
make -C use-cases/onprem-basic validate
make -C use-cases/onprem-basic status
make -C use-cases/onprem-basic clean
```

## Qué hace `make up`

1. Refresca metadata generada a partir de las IPs declaradas de `server` y `agent`.
2. Valida `SSH`, `sudo`, `systemd` y la matriz de runtimes soportados.
3. Copia el bundle de `productive-k3s` a las máquinas destino.
4. Ejecuta el modo `server` sobre `ONPREM_SERVER_IP`.
5. Captura el token de nodo de K3S.
6. Ejecuta el modo `agent` sobre cada IP declarada como agente.
7. Sincroniza aliases de Rancher y registry entre los nodos.
8. Ejecuta el modo `stack` sobre el servidor.
9. Valida nodos, servicios compartidos, ingress y storage por defecto.

## Notas

!!! note
    Este caso de uso no provisiona máquinas. Asume que la infraestructura ya existe.

!!! note
    La misma capa compartida de bootstrap remoto también se reutiliza desde `aws-single-node`, lo que mantiene alineado el comportamiento del lado `SSH`.

!!! note
    La cobertura pública de validación incluye hoy tanto un patrón de host único como un patrón `server + agent`.
