# Secondary Cluster
module "secondary-cluster" {
  name                    = var.cluster_name
  project_id              = var.project_id
  source                  = "terraform-google-modules/kubernetes-engine/google//modules/beta-public-cluster"
  version                 = "13.0.0"
  regional                = false
  region                  = var.secondary_region
  network                 = "default"
  subnetwork              = "default"
  ip_range_pods           = ""
  ip_range_services       = ""
  zones                   = var.secondary_zones
  release_channel         = "REGULAR"
  cluster_resource_labels = { "mesh_id" : "proj-${data.google_project.project.number}" }
  identity_namespace      = "${var.project_id}.svc.id.goog"

  node_pools = [
    {
      name         = var.node_pool
      autoscaling  = false
      auto_upgrade = true

      node_count   = 4
      machine_type = "e2-standard-4"
    },
  ]

}