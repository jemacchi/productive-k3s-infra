# Testing And Matrix

The repository exposes a three-level validation model.

## Root matrix levels

- `static`: shell syntax, Python compile checks, OpenTofu validation, and selected behavior tests
- `contract`: checks that each public use case exposes the expected files, outputs, ignores, and targets
- `live`: executes the real environment flow when the environment allows it

## Root commands

```bash
make test-static
make test-contract
make test-live
make test-matrix
```

## Main test entry points

- `tests/run-matrix.sh`
- `tests/contract-check.sh`
- `tests/live-multipass.sh`
- `tests/live-onprem-basic.sh`
- telemetry-specific regression scripts under `tests/`

## Artifact model

Matrix runs write JSON manifests under `test-artifacts/`.

Those artifacts record:

- use case
- level
- result
- duration
- topology and environment class
- selected Productive K3S source details
- anonymous telemetry-related metadata

## Development guidance

When changing a public use case, review whether you need to update:

- the use-case-local `test-static` target
- the contract expectations in `tests/contract-check.sh`
- any telemetry propagation tests
- the generated metadata contract consumed by matrix manifests

## Notes

!!! note
    `aws-single-node` intentionally skips the public `live` test unless AWS credentials and an account are available. That skip behavior is part of the current public contract.
