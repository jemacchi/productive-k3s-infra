# Privacy And Telemetry

`productive-k3s-infra` produces anonymous test-run manifests for matrix executions and direct scenario test runs.

## Goals

- keep CI and local regression evidence structured and shareable
- make future telemetry behavior auditable in a public repository
- avoid embedding environment-specific identifiers into telemetry-facing artifacts

## Anonymous test artifacts

Matrix executions and direct scenario test targets write JSON artifacts under `test-artifacts/`.

The shared scenario manifests live under `test-artifacts/infra-runs/`, and matrix layers also emit root `*-summary.json` files under `test-artifacts/`.

They are meant to capture:

- scenario name
- test level
- result
- duration
- environment kind
- expected topology
- bootstrap modes exercised

They are not meant to capture:

- IP addresses
- hostnames
- usernames
- local filesystem paths
- cloud account identifiers
- SSH targets

## Resolution rules

- if `TELEMETRY_ENABLED` is explicitly set to `true` or `false`, that value is used as-is
- if `TELEMETRY_ENABLED` is unset and the run is interactive, the repository prompts once and defaults to `Yes`
- if `TELEMETRY_ENABLED` is unset and the run is non-interactive, it resolves to `false`
- root matrix values are propagated into each scenario
- each scenario propagates the same telemetry values into nested `productive-k3s-core` bootstrap commands

## Supported propagated variables

- `TELEMETRY_ENABLED`
- `TELEMETRY_ENDPOINT`
- `TELEMETRY_MAX_RETRIES`
- `TELEMETRY_CONNECT_TIMEOUT_SECONDS`
- `TELEMETRY_REQUEST_TIMEOUT_SECONDS`
- `TELEMETRY_OUTBOX_DIR`
- `TELEMETRY_USER_AGENT`

## Notes

!!! note
    Infrastructure artifacts remain anonymous by default. A shareable run manifest may record that telemetry was enabled, but it should not expose endpoint values.

!!! note
    In this repository telemetry is part of an explicit operator contract, not a hidden side effect.
