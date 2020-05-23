data "scaleway_instance_image" "centos" {
  name = "dcos-base-image"  # CentOS 7.6 with Docker, NTP installed
  architecture = "x86_64"
}

resource "scaleway_instance_server" "bootstrap" {
  name              = "dcos-bootstrap"
  image             = data.scaleway_instance_image.centos.id
  type              = var.server_type
  security_group_id = scaleway_instance_security_group.dcos_cluster_private.id

  connection {
    host        = self.public_ip
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/id_rsa")
  }

  # provide means for the bootstrap to connect to cluster nodes 
  provisioner "file" {
    source  = "~/.ssh/id_rsa"
    destination = "~/.ssh/id_rsa"
  }

  # provisioner "file" {
  #   source  = "~/.ssh/id_rsa.pub"
  #   destination = "~/.ssh/id_rsa.pub"
  # }
}

resource "scaleway_instance_server" "master" {
  count             = var.nb_nodes_master
  name              = "${var.master_root_name}-${count.index}"
  image             = data.scaleway_instance_image.centos.id
  type              = var.server_type
  security_group_id = scaleway_instance_security_group.dcos_cluster_private.id
  enable_dynamic_ip = true 
}

resource "scaleway_instance_server" "public_agent" {
  count             = var.nb_nodes_public_agent
  name              = "${var.public_agent_root_name}-${count.index}"
  image             = data.scaleway_instance_image.centos.id
  type              = var.server_type
  security_group_id = scaleway_instance_security_group.dcos_cluster_public.id
  enable_dynamic_ip = true 
}

resource "scaleway_instance_server" "private_agent" {
  count             = var.nb_nodes_private_agent
  name              = "${var.private_agent_root_name}-${count.index}"
  image             = data.scaleway_instance_image.centos.id
  type              = var.server_type
  security_group_id = scaleway_instance_security_group.dcos_cluster_private.id
  enable_dynamic_ip = true 
}

resource "scaleway_instance_security_group" "dcos_cluster_private" {
  name = "dcos-cluster-private-agents"
  description = "Private Network Access policies around DC/OS Cluster"
  
  external_rules = true
  inbound_default_policy = "drop"
}

resource "scaleway_instance_security_group_rules" "dcos_cluster_private_ssh" {
  security_group_id = scaleway_instance_security_group.dcos_cluster_private.id

  inbound_rule {
    action = "accept"
    ip_range = "0.0.0.0/0"
    protocol = "TCP"
    port = "22"
  }  
}

resource "scaleway_instance_security_group_rules" "security-rules-cluster-nodes" {
  security_group_id = scaleway_instance_security_group.dcos_cluster_private.id

  dynamic "inbound_rule" {
    for_each = concat(scaleway_instance_server.master.*.private_ip, scaleway_instance_server.public_agent.*.private_ip, scaleway_instance_server.private_agent.*.private_ip)
    content {
      action = "accept"
      ip = inbound_rule.value
      protocol = "TCP"
    }
  }
}

resource "scaleway_instance_security_group_rules" "dcos_cluster_private_inbound_home" {
  security_group_id = scaleway_instance_security_group.dcos_cluster_private.id

  inbound_rule {
    action = "accept"
    ip = "82.79.248.51"
    protocol = "TCP"
  }  
}

resource "scaleway_instance_security_group_rules" "dcos_cluster_private_outbound_all" {
  security_group_id = scaleway_instance_security_group.dcos_cluster_private.id

  outbound_rule {
    action = "accept"
    ip_range = "0.0.0.0/0"
    protocol = "TCP"
  }
}

resource "scaleway_instance_security_group" "dcos_cluster_public" {
  name = "dcos-cluster-public-agents"
  description = "Public Network Access policies around DC/OS Cluster"
  external_rules = true
}

resource "scaleway_instance_security_group_rules" "dcos_cluster_public_inbound_all" {
  security_group_id = scaleway_instance_security_group.dcos_cluster_public.id

  inbound_rule {
    action = "accept"
    ip_range = "0.0.0.0/0"
    protocol = "TCP"
  }  
}