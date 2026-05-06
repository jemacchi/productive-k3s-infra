# On-Prem Basic Use Case

`onprem-basic` bootstraps `productive-k3s` onto machines that already exist and are reachable over `SSH`.

## What it expects

- one declared `server` IP
- zero or more declared `agent` IPs
- a reachable remote user
- passwordless `sudo`
- a supported Ubuntu or Debian runtime

## Main commands

```bash
make -C use-cases/onprem-basic preflight
make -C use-cases/onprem-basic up
make -C use-cases/onprem-basic validate
make -C use-cases/onprem-basic status
make -C use-cases/onprem-basic clean
```

## What `make up` does

1. Refreshes generated metadata from the declared `server` and `agent` IPs.
2. Validates `SSH`, `sudo`, `systemd`, and the supported runtime matrix.
3. Copies the `productive-k3s` bundle to the target machines.
4. Runs `server` mode on `ONPREM_SERVER_IP`.
5. Captures the K3S node token.
6. Runs `agent` mode on every declared agent IP.
7. Synchronizes Rancher and registry aliases across the nodes.
8. Runs `stack` mode on the server.
9. Validates nodes, shared services, ingress, and default storage.

## Notes

!!! note
    This use case does not provision machines. It assumes the infrastructure already exists.

!!! note
    The same shared remote bootstrap layer is reused by `aws-single-node`, which keeps the SSH-side behavior aligned across both remote flows.

!!! note
    Public validation coverage currently includes both a single-host and a `server + agent` pattern.
