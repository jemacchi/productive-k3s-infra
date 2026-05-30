output "cluster_name" {
  value = var.cluster_name
}

output "base_domain" {
  value = var.base_domain
}

output "remote_dir" {
  value = var.remote_dir
}

output "server_name" {
  value = local.server_name
}

output "agent_names" {
  value = [local.agent1_name, local.agent2_name]
}

output "rancher_host" {
  value = local.rancher_host
}

output "registry_host" {
  value = local.registry_host
}

output "cluster_metadata" {
  value = try(jsondecode(file("${path.module}/../generated/cluster.json")), null)
}
