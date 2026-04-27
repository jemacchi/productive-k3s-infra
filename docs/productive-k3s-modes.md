# Productive K3S Modes

Productive K3S should expose explicit installation modes so that infrastructure automation can assemble clusters predictably.

Recommended implementation order:

1. `single-node`: current default behavior, complete setup on one node.
2. `server`: initializes or joins a K3S server node.
3. `agent`: joins an existing K3S server.
4. `stack`: installs cluster-level components after the cluster exists.

The split allows OpenTofu and Ansible to create machines first, assemble the cluster second, and install the platform stack last.
