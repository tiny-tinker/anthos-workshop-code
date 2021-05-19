module "hub-secondary" {
  source           = "terraform-google-modules/kubernetes-engine/google//modules/hub"

  project_id       = data.google_client_config.current.project
  cluster_name     = module.secondary-cluster.name
  location         = module.secondary-cluster.location
  cluster_endpoint = module.secondary-cluster.endpoint
  gke_hub_membership_name = var.membership_name
  //gke_hub_sa_name = var.hub_sa_name
}

