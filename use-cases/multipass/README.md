# Multipass Use Case

Local multi-node Productive K3S infrastructure using Multipass virtual machines.

This should be the first advanced use case implemented because it provides a safe local environment to validate the future Productive K3S modes:

- `server`
- `agent`
- `stack`

Expected flow:

1. OpenTofu creates local Multipass VMs.
2. Ansible configures SSH access and node prerequisites.
3. Productive K3S initializes the first node in `server` mode.
4. Additional nodes join in `agent` mode.
5. Productive K3S installs the shared platform components in `stack` mode.

This use case is public because it drives adoption, demos, and development validation.
