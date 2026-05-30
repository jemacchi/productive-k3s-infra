# How To Use Productive K3S Infra

`productive-k3s-infra` is now organized around profiles as the public entrypoint, with complete scenario implementations still living under `scenarios/`.

## Choose the matching profile

- `multipass-1-server-2-agents`: local three-node cluster on top of Multipass VMs
- `on-prem-basic` / `on-prem-arm`: bootstrap existing hosts over `SSH`
- `aws-single-node-basic`: provision one `EC2` instance with `OpenTofu` and bootstrap it remotely

## Understand the execution contract

Each scenario is responsible for the infrastructure around the cluster, while `productive-k3s-core` remains responsible for the cluster bootstrap itself.

In practice that means `productive-k3s-infra` handles:

- host creation or host targeting
- generated inventories and cluster metadata
- bundle copy from a local checkout or a remote release
- orchestration of `server`, `agent`, and `stack` phases when the scenario needs them
- scenario-specific validation

## Optional K3S install engine

The default engine remains the native Productive K3S bootstrap path.

Advanced users can also opt into:

```bash
PRODUCTIVE_K3S_ENGINE=k3sup
```

This is intentionally documented as experimental.

Why it exists:

- to show that `k3sup` can complement `productive-k3s-core`
- to let advanced users experiment with the same opinionated Productive K3S platform decisions while using a familiar K3S install backend

What it does not mean:

- `k3sup` is not the product
- `k3sup` does not replace the Productive K3S bootstrap contract
- `k3sup` does not expand the public support matrix beyond the repository's documented VM, OS, and scenario coverage

If you enable the experimental engine, you are still inside the Productive K3S support model only where the repository matrix and tests explicitly cover it.
Outside that scope, especially in custom or manually orchestrated combinations, the responsibility shifts to the experimenting user.

## Choose the Productive K3S Core source mode

Most public scenarios support two source modes:

- `PRODUCTIVE_K3S_SOURCE=local`: package a sibling local checkout of `productive-k3s-core`
- `PRODUCTIVE_K3S_SOURCE=remote`: download a published GitHub Release bundle

If `remote` is used, `PRODUCTIVE_K3S_VERSION` can pin a specific release. If it is omitted, the scenario resolves the latest release from `PRODUCTIVE_K3S_RELEASE_REPO`.

When you use the published `productive-k3s-infra-cli.sh` from a GitHub Release, that release already binds a specific `productive-k3s-core` release. In that path, the CLI forces:

- `PRODUCTIVE_K3S_SOURCE=remote`
- `PRODUCTIVE_K3S_VERSION=A.B.C`

The `A.B.C` segment comes from the infra release tag `X.Y.Z-A.B.C`.

## Use the public entry points

The public operator interface is:

- package-based runtime commands on `productive-k3s-infra.sh`
- package resolution by higher-level tools such as `pk3s`

Public runtime examples:

```bash
./productive-k3s-infra.sh profile validate --tgz ./multipass-1-server-2-agents.tgz
./productive-k3s-infra.sh profile install --tgz ./aws-single-node-basic.tgz
pk3s profile validate multipass-1-server-2-agents
pk3s infra install aws-single-node-basic
```

## Use the development entry points

Source-based `.env` profiles remain valid for repository development, CI, and authoring workflows.

Development examples:

```bash
./productive-k3s-infra.sh dev profile validate --profile-env ./profiles/edge/on-prem/basic.env
./productive-k3s-infra.sh dev profile plan --profile-env ./profiles/local/multipass/1-server-2-agents.env
./productive-k3s-infra.sh dev profile apply --profile-env ./profiles/cloud/aws-single-node/basic.env
make infra-validate PROFILE=profiles/edge/on-prem/basic.env
make infra-plan PROFILE=profiles/local/multipass/1-server-2-agents.env
```

Use `dev profile validate` when you only want to check that the `.env` contract is valid. Use scenario `validate` or the corresponding `make` target when you want the scenario-specific post-provision validation, which may require generated runtime state such as inventories or cluster metadata.

Typical scenario command patterns:

- infrastructure only: `infra-up`
- preflight only: `preflight`
- full bootstrap: `up`
- validation only: `validate`
- inspect generated state: `status`
- cleanup or teardown: `clean` or `down`

See [Make targets](../user-docs/make-targets.md) for the detailed matrix.

## Notes

!!! note
    These public scenarios are intentionally pragmatic. They are meant to be evaluable, reusable, and explainable. They are not presented as fully hardened production blueprints.

!!! note
    Generated artifacts under each scenario are part of the public workflow. They make infrastructure decisions, bootstrap inputs, and validation state easier to inspect.
