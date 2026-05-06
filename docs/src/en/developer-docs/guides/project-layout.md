# Project Layout

The repository is organized around public use cases plus shared infrastructure layers.

## Top-level structure

```text
productive-k3s-infra/
  use-cases/
    multipass/
    onprem-basic/
    aws-single-node/
  ansible/
    roles/
      remote_cluster/
  opentofu/
    modules/
  tests/
  docs/
```

## Responsibility split

- `use-cases/`: public entry points and operator-facing workflows
- `ansible/roles/remote_cluster`: shared remote bootstrap and validation assets
- `opentofu/`: shared infrastructure building blocks and forward-looking module space
- `tests/`: static, contract, and live validation entry points
- `docs/`: bilingual documentation site

## Generated artifacts

Each use case writes generated metadata under its own `generated/` directory, typically including:

- `cluster.json`
- `hosts.yml`
- `server-token.txt`
- logs or provider-specific outputs when applicable

These artifacts are part of the workflow because they expose the resolved runtime view of the use case.

## Notes

!!! note
    The repository is intentionally centered on `use-cases/`, not on low-level helpers. Public users should start from a deployment path, not from an implementation detail.
