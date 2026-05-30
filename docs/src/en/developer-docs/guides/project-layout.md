# Project Layout

The repository is organized around versioned profiles as the public configuration entrypoint, plus scenario implementations and shared infrastructure layers.

## Top-level structure

```text
productive-k3s-infra/
  profiles/
    cloud/
    edge/
    local/
  scenarios/
    cloud/
      aws-single-node/
    edge/
      onprem-basic/
      onprem-basic-arm/
    local/
      multipass/
  ansible/
    roles/
      remote_cluster/
  opentofu/
    modules/
  tests/
  docs/
```

## Responsibility split

- `profiles/`: versioned public configuration examples for the profile-driven CLI
- `scenarios/`: scenario implementations and operator-facing workflows
- `ansible/roles/remote_cluster`: shared remote bootstrap and validation assets
- `opentofu/`: shared infrastructure building blocks and forward-looking module space
- `tests/`: static, contract, and live validation entry points
- `docs/`: bilingual documentation site

## Generated artifacts

Each scenario writes generated metadata under its own `generated/` directory, typically including:

- `cluster.json`
- `hosts.yml`
- `server-token.txt`
- logs or provider-specific outputs when applicable

These artifacts are part of the workflow because they expose the resolved runtime view of the scenario.

## Notes

!!! note
    Public users should now start from `profiles/` and the profile-driven CLI. `scenarios/` remains the implementation layer behind those entry points.

!!! note
    Canonical paths are now category-oriented, such as `profiles/cloud/...` or `scenarios/edge/...`. Legacy top-level paths remain available as compatibility aliases.
