# On-Prem Basic Scenario

`onprem-basic` bootstraps `productive-k3s-core` onto machines that already exist and are reachable over `SSH`.

## What it expects

- one declared `server` IP
- zero or more declared `agent` IPs
- a reachable remote user
- passwordless `sudo`
- a supported Ubuntu or Debian runtime
- a `productive-k3s-core` bundle source that can be copied to the remote host before bootstrap

## Main commands

```bash
make -C scenarios/edge/onprem-basic preflight
make -C scenarios/edge/onprem-basic up
make -C scenarios/edge/onprem-basic validate
make -C scenarios/edge/onprem-basic status
make -C scenarios/edge/onprem-basic clean
```

## What `make up` does

1. Refreshes generated metadata from the declared `server` and `agent` IPs.
2. Validates `SSH`, `sudo`, `systemd`, and the supported runtime matrix.
3. Copies the `productive-k3s-core` bundle to the target machines.
4. Runs the remote `productive-k3s-core` host preflight when the copied bundle exposes `scripts/preflight-host.sh`.
5. Runs `server` mode on `ONPREM_SERVER_IP`.
6. Captures the K3S node token.
7. Runs `agent` mode on every declared agent IP.
8. Synchronizes Rancher and registry aliases across the nodes.
9. Runs `stack` mode on the server.
10. Validates nodes, shared services, ingress, and default storage.

## What `make preflight` does

`make preflight` is now deeper than a pure reachability probe. It:

1. refreshes generated metadata
2. validates `SSH`, `sudo`, `systemd`, and the public runtime matrix
3. copies the `productive-k3s-core` bundle to the target machines
4. runs the remote host preflight from `productive-k3s-core` when that bundle contains `scripts/preflight-host.sh`

If the copied `productive-k3s-core` bundle does not yet expose that helper, the scenario logs a warning and continues with the shared infrastructure-side preflight only.

## Notes

!!! note
    This scenario does not provision machines. It assumes the infrastructure already exists.

!!! note
    The same shared remote bootstrap layer is reused by `aws-single-node`, which keeps the SSH-side behavior aligned across both remote flows.

!!! note
    The GitHub-hosted public live workflow for `onprem-basic` also goes through this path. If the checked out `productive-k3s-core` revision already includes `scripts/preflight-host.sh`, that hosted live run exercises the remote host preflight too.

!!! note
    Public validation coverage currently includes both a single-host and a `server + agent` pattern.
