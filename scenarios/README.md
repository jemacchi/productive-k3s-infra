# Scenarios

This folder contains pre-assembled infrastructure solutions.

The term `scenarios` is intentional. These are not minimal examples. Each folder should describe a practical deployment path that can be used as a starting solution when it matches the user's needs.

Current public paths are organized by category:

- `local/multipass`: creates local VMs and bootstraps a three-node cluster
- `cloud/aws-single-node`: provisions a basic single-node `EC2` path with `OpenTofu` and bootstraps it over `SSH`
- `edge/onprem-basic`: bootstrap existing machines by declaring a `server` IP and optional `agent` IPs over SSH
- `edge/onprem-basic-arm`: same remote bootstrap path, but documented as a public ARM-oriented entrypoint for Raspberry Pi and similar Ubuntu `24.04` `arm64` hosts

Legacy top-level paths remain available as compatibility aliases.
