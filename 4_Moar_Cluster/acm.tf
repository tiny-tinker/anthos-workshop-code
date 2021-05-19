module "acm-secondary" {
  source           = "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/acm"

  project_id       = data.google_client_config.current.project
  cluster_name     = module.secondary-cluster.name
  location         = module.secondary-cluster.location
  cluster_endpoint = module.secondary-cluster.endpoint

  operator_path    = "config-management-operator.yaml"
  sync_repo        = var.acm_repo_location
  sync_branch      = var.acm_branch
  policy_dir       = var.acm_dir
}