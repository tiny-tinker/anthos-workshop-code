variable "project_id" {
  description = "The project ID to host the cluster in"
}

variable "cluster_name" {
    description = "The name of the cluster"
}
variable "secondary_region" {
  description = "The secondary region to be used"
}
variable "secondary_zones" {
  description = "The secondary zones to be used"
}

variable "node_pool" {
    description = "The name of the node pool to add"
}

variable "membership_name" {
    description = "The name of the hub membership to register on the cluster"
}

variable "hub_sa_name" {
    description = "The name of the service account to associate"
}

variable "acm_repo_location" {
  description = "The location of the git repo ACM will sync to"
}

variable "acm_branch" {
  description = "The git branch ACM will sync to"
}

variable "acm_dir" {
  description = "The directory in git ACM will sync to"
}