output bootstrap {
  value       = {
    public_ip   = scaleway_instance_server.bootstrap.public_ip
    private_ip  = scaleway_instance_server.bootstrap.private_ip
    prereq-id   = ""
  }
  depends_on  = []
}

output masters {
  value       = {
    private_ips = scaleway_instance_server.master.*.private_ips
  }
  depends_on  = []
}

output private_agents {
  value       = {
    private_ips = scaleway_instance_server.private_agent.*.private_ips
  }
  depends_on  = []
}

output public_agents {
  value       = {
    private_ips = scaleway_instance_server.public_agent.*.private_ips
  }
  depends_on  = []
}



