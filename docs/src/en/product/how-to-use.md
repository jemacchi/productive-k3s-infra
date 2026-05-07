# How To Use Productive K3S Infra

`productive-k3s-infra` is organized around complete use cases under `use-cases/`, not around isolated snippets.

## Choose the matching use case

- `multipass`: local three-node cluster on top of Multipass VMs
- `onprem-basic`: bootstrap existing hosts over `SSH`
- `aws-single-node`: provision one `EC2` instance with `OpenTofu` and bootstrap it remotely

## Understand the execution contract

Each use case is responsible for the infrastructure around the cluster, while `productive-k3s` remains responsible for the cluster bootstrap itself.

In practice that means `productive-k3s-infra` handles:

- host creation or host targeting
- generated inventories and cluster metadata
- bundle copy from a local checkout or a remote release
- orchestration of `server`, `agent`, and `stack` phases when the use case needs them
- use-case-specific validation

## Choose the Productive K3S source mode

Most public use cases support two source modes:

- `PRODUCTIVE_K3S_SOURCE=local`: package a sibling local checkout of `productive-k3s`
- `PRODUCTIVE_K3S_SOURCE=remote`: download a published GitHub Release bundle

If `remote` is used, `PRODUCTIVE_K3S_VERSION` can pin a specific release. If it is omitted, the use case resolves the latest release from `PRODUCTIVE_K3S_RELEASE_REPO`.

## Use the public entry points

The public operator interface is:

- the release CLI: `productive-k3s-infra-cli.sh`
- local `make` shortcuts at the repository root
- direct `make -C use-cases/...` commands when you want to work inside one use case explicitly

Release CLI examples:

```bash
curl -fsSL https://github.com/<owner>/<repo>/releases/download/vX.Y.Z/productive-k3s-infra-cli.sh | bash -s -- multipass up
curl -fsSL https://github.com/<owner>/<repo>/releases/download/vX.Y.Z/productive-k3s-infra-cli.sh | bash -s -- onprem preflight
curl -fsSL https://github.com/<owner>/<repo>/releases/download/vX.Y.Z/productive-k3s-infra-cli.sh | bash -s -- aws-single-node validate
```

Root Makefile shortcuts:

```bash
make multipass
make onprem
make aws-single-node
```

Typical use-case command patterns:

- infrastructure only: `infra-up`
- preflight only: `preflight`
- full bootstrap: `up`
- validation only: `validate`
- inspect generated state: `status`
- cleanup or teardown: `clean` or `down`

See [Make targets](../user-docs/make-targets.md) for the detailed matrix.

## Notes

!!! note
    These public use cases are intentionally pragmatic. They are meant to be evaluable, reusable, and explainable. They are not presented as fully hardened production blueprints.

!!! note
    Generated artifacts under each use case are part of the public workflow. They make infrastructure decisions, bootstrap inputs, and validation state easier to inspect.
