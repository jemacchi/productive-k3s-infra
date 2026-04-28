# Multipass Flow

The Multipass use case is the preferred local validation path for multi-node Productive K3S.

Flow:

1. Create three Ubuntu VMs with OpenTofu and Multipass.
2. Generate cluster metadata and an inventory file from the live VM IP addresses.
3. Copy the local `productive-k3s` repository into each VM.
4. Run Productive K3S `server` mode on the first node.
5. Capture the node token from `/var/lib/rancher/k3s/server/node-token`.
6. Run Productive K3S `agent` mode on the remaining nodes.
7. Synchronize internal Rancher and registry host aliases into each VM.
8. Run Productive K3S `stack` mode once all nodes are ready.
9. Validate the cluster with multi-node-aware checks.
