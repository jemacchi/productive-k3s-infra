# Multipass Scenario

`multipass` is the preferred local validation path for a multi-node Productive K3S Core environment.

## What it builds

- `1` server VM
- `2` agent VMs
- shared `stack` installed on the server after the cluster is assembled

## Main commands

```bash
make -C scenarios/multipass infra-up
make -C scenarios/multipass cluster-up
make -C scenarios/multipass up
make -C scenarios/multipass validate
make -C scenarios/multipass status
make -C scenarios/multipass down
make -C scenarios/multipass clean
```

## What `make up` does

1. Launches the three VMs through `OpenTofu` and Multipass.
2. Renders generated metadata from the live VM IPs.
3. Prepares a `productive-k3s-core` bundle from `local` or `remote` source.
4. Runs `server` mode on the first node.
5. Captures the server join token.
6. Runs `agent` mode on the remaining nodes.
7. Synchronizes Rancher and registry aliases inside the VMs.
8. Runs `stack` mode on the server.
9. Validates node readiness, core namespaces, ingress reachability, and storage defaults.

## Notes

!!! note
    This scenario does not currently update `/etc/hosts` on the control machine. Rancher and registry hostnames are guaranteed inside the VMs, not automatically on the host.

!!! note
    A first `Rancher` install on a cold cluster can spend several minutes in `ContainerCreating` while images are pulled.

!!! note
    This is the best public path when you want to exercise the split `server` and `agent` model locally.
