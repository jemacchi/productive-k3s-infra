# Multipass Flow

The Multipass use case is the preferred local validation path for multi-node Productive K3S.

Flow:

1. Create VMs with OpenTofu.
2. Generate or export an Ansible inventory.
3. Prepare all nodes with Ansible.
4. Run Productive K3S `server` mode on the first node.
5. Run Productive K3S `agent` mode on the remaining nodes.
6. Run Productive K3S `stack` mode once all nodes are ready.
7. Validate the cluster.
