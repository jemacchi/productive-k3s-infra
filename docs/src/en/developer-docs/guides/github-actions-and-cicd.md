# CI/CD Flow

This repository already has a CI-friendly validation model even though the current public tree does not include GitHub Actions workflow files.

## What exists today

- deterministic root `make` targets for docs and matrix validation
- structured `static`, `contract`, and `live` levels
- anonymous JSON artifacts under `test-artifacts/` for run evidence
- a clear split between operator entry points and implementation scripts

## Practical CI/CD model

In CI, the intended flow is:

1. run `make test-static`
2. run `make test-contract`
3. run the live layer only where the environment supports it
4. keep the resulting artifacts as evidence

## Why document it now

Even without checked-in workflows, documenting the CI/CD contract matters because:

- it stabilizes the repository interface
- it defines what future automation should call
- it keeps local and CI execution aligned

## Notes

!!! note
    This page describes the current repository execution model and CI/CD shape. It does not claim that a full GitHub Actions implementation is already present in the public tree.
