# based on DCOS universal installer published here:
# https://github.com/dcos-terraform/terraform-null-dcos-install-remote-exec-ansible


# configure the authentication credentials for 
# accessing the provider of the cloud resources
provider "scaleway" {
  access_key      = var.provider_access_key
  secret_key      = var.provider_secret_key
  organization_id = var.organization_id
  region          = "nl-ams"
  zone            = "nl-ams-1"    
}

module "dcos-infrastructure" {
  source                  = "./modules/dcos-infrastructure"
  nb_nodes_master         = 1
  nb_nodes_public_agent   = 1
  nb_nodes_private_agent  = 3 
}

data "http" "whatismyip" {
  url = "http://whatismyip.akamai.com/"
}

module "dcos-install" {
  source = "dcos-terraform/dcos-install-remote-exec-ansible/null"
  version = "~> 0.2.10"

  dcos_variant                  = "open"
  dcos_version                  = "1.13.6"
  dcos_download_url             = "https://downloads.dcos.io/dcos/stable/dcos_generate_config.sh"
  dcos_version_to_upgrade_from  = "1.13.6"

  bootstrap_ip                = "${module.dcos-infrastructure.bootstrap.public_ip}"
  bootstrap_private_ip        = "${module.dcos-infrastructure.bootstrap.private_ip}"
  master_private_ips          = ["${module.dcos-infrastructure.masters.private_ips}"]
  private_agent_private_ips   = ["${module.dcos-infrastructure.private_agents.private_ips}"]
  public_agent_private_ips    = ["${module.dcos-infrastructure.public_agents.private_ips}"]

  bootstrap_os_user = "root"

  dcos_config_yml = <<EOF
  cluster_name: "dcos-cluster"
  bootstrap_url: http://${module.dcos-infrastructure.bootstrap.private_ip}:8080
  exhibitor_storage_backend: static
  master_discovery: static
  master_list: ["${join("\",\"", module.dcos-infrastructure.masters.private_ips)}"]
  EOF

  # depends_on = ["${module.dcos-infrastructure.bootstrap.prereq-id}"]
}