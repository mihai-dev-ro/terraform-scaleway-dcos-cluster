variable nb_nodes_master {
  type        = number
  default     = 1
  description = "number of master nodes in the cluster"
}

variable nb_nodes_public_agent {
  type        = number
  default     = 1
  description = "number of public agents in the cluster"
}

variable nb_nodes_private_agent {
  type        = number
  default     = 1
  description = "number of private agents in the cluster"
}

variable server_type {
  type        = string
  default     = "DEV1-S"
  description = "the commercial type of the image defined by Scaleway"
}

variable master_root_name {
  type        = string
  default     = "dcos-master-"
  description = "root name given to all master instances"
}

variable public_agent_root_name {
  type        = string
  default     = "dcos-public-agent-"
  description = "root name given to all master instances"
}

variable private_agent_root_name {
  type        = string
  default     = "dcos-private-agent-"
  description = "root name given to all master instances"
}


