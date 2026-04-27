# Productive K3S Infra

**Productive K3S Infra** provides pre-assembled infrastructure use cases for running [Productive K3S](https://github.com/jemacchi/productive-k3s) in repeatable local, cloud, and on-premises environments.

The goal of this repository is not to replace Productive K3S. Instead, it acts as the infrastructure companion project: it prepares machines, networking assumptions, inventories, and provisioning flows so that Productive K3S can bootstrap a useful K3S environment on top.

## Positioning

Productive K3S focuses on a simple, production-like K3S setup, especially for single-node scenarios.

Productive K3S Infra focuses on the surrounding infrastructure:

- local virtual machines with Multipass
- basic AWS single-node provisioning
- basic on-premises provisioning over SSH
- reusable OpenTofu modules
- reusable Ansible roles

This repository is intended to provide **pre-assembled solutions**, not toy examples. For that reason, the main entry points are organized as `use-cases/`.

## Repository structure

```text
productive-k3s-infra/
  use-cases/
    multipass/
    aws-single-node/
    onprem-basic/
  ansible/
    roles/
  opentofu/
    modules/
      base-vm/
      k3s-single-node/
  docs/
```

## Open vs. Pro boundary

This public repository should contain the use cases that help adoption and make the project easy to evaluate:

- local Multipass environments
- basic single-node cloud provisioning
- basic on-premises provisioning
- reusable low-level modules and roles

Production-grade compositions such as HA clusters, hardened networking, backup/restore automation, upgrade workflows, and managed customer deployments can live in a private companion repository, for example:

- `productive-k3s-infra-pro`

That repository can consume this one through:

- OpenTofu remote module sources
- Ansible `requirements.yml`

Submodules are not required for the intended architecture.

## Expected Productive K3S modes

To support infrastructure-driven provisioning, Productive K3S should evolve from a single default installer into a small set of explicit modes.

Recommended sequence:

### 1. `single-node` mode

Default mode. Installs a complete Productive K3S stack on one machine.

This is the current primary use case and should remain the simplest path.

### 2. `server` mode

Installs a K3S server node.

Responsibilities:

- initialize or join the control plane
- expose the K3S token or accept a provided token
- configure server-specific components
- avoid installing agent-only assumptions

### 3. `agent` mode

Installs a K3S agent node.

Responsibilities:

- join an existing server
- receive the server URL and cluster token
- avoid initializing cluster-wide components

### 4. `stack` mode

Installs or validates the Productive K3S add-on stack after the cluster exists.

This may include:

- cert-manager
- Longhorn
- Rancher
- internal registry
- ingress configuration
- validation checks

This mode is useful for multi-node environments where infrastructure creation and cluster joining happen first, and application-level cluster services are installed afterwards.

## Multipass provisioning flow

The first full infrastructure use case should be Multipass because it allows local validation without requiring cloud credentials.

Recommended flow:

1. OpenTofu creates the Multipass virtual machines.
2. OpenTofu outputs IP addresses and node metadata.
3. Ansible consumes the generated inventory.
4. Ansible runs Productive K3S in `server` mode on the first node.
5. Ansible retrieves or receives the K3S token.
6. Ansible runs Productive K3S in `agent` mode on the remaining nodes.
7. Ansible runs Productive K3S in `stack` mode once the cluster is assembled.
8. Validation checks confirm node readiness, storage, ingress, and core services.

## License

Apache License 2.0. See [LICENSE](./LICENSE).
