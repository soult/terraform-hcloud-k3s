resource "local_file" "ssh_config" {
  count    = var.create_scripts ? 1 : 0
  filename = "./.ssh/config"
  content = templatefile(
    "${path.module}/templates/ssh_config", {
      cluster_name          = var.cluster_name
      cluster_ip            = hcloud_server.gateway.ipv4_address
      control_plane_main_ip = hcloud_server_network.control_plane_main.ip
      node_pools            = module.node_pools
      cwd                   = path.cwd
    }
  )
  file_permission = "0600"
}

resource "local_file" "scp-node" {
  count    = var.create_scripts ? 1 : 0
  filename = "./scp-node"
  content = templatefile(
    "${path.module}/templates/scp-node", {
      cwd = path.cwd
    }
  )
  file_permission = "0755"
}

resource "local_file" "ssh-node" {
  count    = var.create_scripts ? 1 : 0
  filename = "./ssh-node"
  content = templatefile(
    "${path.module}/templates/ssh-node", {
      cwd = path.cwd
    }
  )
  file_permission = "0755"
}

resource "local_file" "ls-nodes" {
  count    = var.create_scripts ? 1 : 0
  filename = "./ls-nodes"
  content = templatefile(
    "${path.module}/templates/ls-nodes", {
      cwd = path.cwd
    }
  )
  file_permission = "0755"
}