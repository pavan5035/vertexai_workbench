

resource "google_project_service" "apis" {
  for_each = toset([
    "compute.googleapis.com",
    "aiplatform.googleapis.com",
    "notebooks.googleapis.com",
    
  ])
  project = var.project_id
  service = each.key
  #service = "aiplatform.googleapis.com"
  timeouts {
    create = "30m"
    update = "40m"
  }
  }