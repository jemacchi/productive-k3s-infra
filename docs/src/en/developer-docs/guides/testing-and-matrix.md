# Testing And Matrix

The repository exposes a three-level validation model.

## Root matrix levels

- `static`: shell syntax, Python compile checks, OpenTofu validation, and selected behavior tests
- `contract`: checks that each public scenario exposes the expected files, outputs, ignores, and targets
- `live`: executes the real environment flow when the environment allows it

## Root commands

```bash
make test-clean
make test
make test-unit
make test-lint
make test-format
make test-spell
make test-coverage
make test-static
make test-contract
make test-live
make test-matrix
make test-checkstatus
```

## Local tooling for fast shell tests

The repo now exposes a local fast layer in addition to `static`, `contract`, and `live`.

- `make test-unit`: `ShellSpec` specs under `tests/spec/`
- `make test-lint`: shell lint for the testing harness
- `make test-format`: `shfmt` check for the testing harness
- `make test-spell`: lightweight spell checks
- `make test-coverage`: shell coverage through `kcov`

If you install tools without root, keep `~/.local/bin` in `PATH`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

User-local install commands used during development on Ubuntu:

```bash
mkdir -p "$HOME/.local/bin" "$HOME/.local/share"
curl -fsSLO https://github.com/koalaman/shellcheck/releases/download/v0.11.0/shellcheck-v0.11.0.linux.x86_64.tar.xz
tar -xJf shellcheck-v0.11.0.linux.x86_64.tar.xz
install shellcheck-v0.11.0/shellcheck "$HOME/.local/bin/shellcheck"

curl -fsSLo "$HOME/.local/bin/shfmt" https://github.com/mvdan/sh/releases/download/v3.13.1/shfmt_v3.13.1_linux_amd64
chmod +x "$HOME/.local/bin/shfmt"

curl -fsSLO https://github.com/shellspec/shellspec/releases/download/0.28.1/shellspec-dist.tar.gz
mkdir -p "$HOME/.local/share/shellspec"
tar -xzf shellspec-dist.tar.gz -C "$HOME/.local/share/shellspec"
cat > "$HOME/.local/bin/shellspec" <<'EOF'
#!/usr/bin/env bash
exec "$HOME/.local/share/shellspec/shellspec/shellspec" "$@"
EOF
chmod +x "$HOME/.local/bin/shellspec"

python3 -m pip install --user codespell
```

`kcov` still needs system development headers on Ubuntu:

```bash
sudo apt-get update
sudo apt-get install -y kcov libelf-dev libdw-dev
```

## Current local coverage baseline

The current maintainer baseline from the latest local `make test-coverage` run is:

- total ShellSpec coverage: `75.14%`
- `ansible/roles/remote_cluster/files/common.sh`: `77.60%`
- `scripts/productive-k3s-infra.sh`: `75.89%`
- `scripts/release-versioning.sh`: `64.29%`
- `scenarios/cloud/aws-single-node/scripts/refresh-generated-artifacts.sh`: `67.92%`
- `scripts/create-release-tag.sh`: `59.09%`

This baseline is intended to guide future additions and refactors. It is not yet enforced as a CI threshold.

## Main test entry points

- `tests/run-matrix.sh`
- `tests/run-scenario-test.sh`
- `tests/check-test-status.sh`
- `tests/clean-test-state.sh`
- `tests/contract-check.sh`
- `tests/live-multipass.sh`
- `tests/live-onprem-basic.sh`
- telemetry-specific regression scripts under `tests/`

## Artifact model

All test entrypoints write JSON artifacts under `test-artifacts/`.

The layout is:

- `test-artifacts/infra-runs/`: one manifest per scenario execution, produced by both matrix runs and direct scenario runs
- `test-artifacts/*-summary.json`: one root summary per matrix layer such as `static`, `contract`, or `live`

Those artifacts record:

- scenario
- level
- result
- skip reason when a scenario is intentionally skipped
- duration
- aggregate matrix start/end timestamps and total duration in the root summary
- topology and environment class
- selected Productive K3S Core source details, preferring the effective resolved values from generated scenario metadata when available
- anonymous telemetry-related metadata

## Local review workflow

Use this sequence when you want a clean, operator-friendly review loop:

```bash
make test-clean
make test-matrix
make test-checkstatus
```

`make test-checkstatus` reads the recorded JSON manifests and prints a short status report instead of forcing you to inspect each file manually.

If you want to inspect only one scenario, run the same targets from the scenario directory:

```bash
make -C scenarios/local/multipass test-clean
make -C scenarios/local/multipass test-static
make -C scenarios/local/multipass test-checkstatus
```

The scenario-local `test-static`, `test-contract`, and `test-live` targets go through `tests/run-scenario-test.sh`, which means they also emit manifests that `make -C scenarios/<name> test-checkstatus` can summarize immediately afterward.

The scenario-local `test-clean` and `test-checkstatus` targets filter the shared `test-artifacts/infra-runs/` state down to the current scenario only.

## Development guidance

When changing a public scenario, review whether you need to update:

- the scenario-local `test-static` target
- the contract expectations in `tests/contract-check.sh`
- `tests/test-k3s-engine-propagation.sh` when the bootstrap wrapper contract changes
- any telemetry propagation tests
- the generated metadata contract consumed by matrix manifests

## Notes

!!! note
    `aws-single-node` intentionally skips the public `live` test unless AWS credentials and an account are available. That skip behavior is part of the current public contract.
