#Create data disk for workbench
resource "google_compute_disk" "data_disk" {
  name  = "my-data-disk"
  type  = "pd-standard"
  zone  = var.zone
  size  = 150  # in GB
  description = " Data disc needed for workbench"
}
#attach disk to workbench instance created below
resource "google_compute_attached_disk" "data_disk" {
  disk     = google_compute_disk.data_disk.self_link
  instance = google_workbench_instance.instance.name
  zone = var.zone
  
}
# assign permissions to service account to manage the attached disk
#resource "google_compute_disk_iam_member" "data_disk_iam" {
#  project = var.project_id
#  zone    = var.zone
#  name    = google_compute_disk.data_disk.name
#  role    = "roles/compute.storage.admin"
#  member  = "serviceAccount:${google_service_account.notebook_sa.email}"
#}

#create workbench instance
resource "google_workbench_instance" "instance" {
  name = "workbench-instance"
  location = var.zone

  gce_setup {
    machine_type = "n1-standard-4" // cant be e2 because of accelerator
     
   service_accounts {
      email = google_service_account.notebook_sa.email
      
    }
     container_image {
      repository = "us-docker.pkg.dev/deeplearning-platform-release/gcr.io/base-cu113.py310"
      tag = "latest"
    }

    # Define the boot disk
    boot_disk {
      disk_size_gb = 150
      disk_type = "PD_SSD" # Replace with your desired disk type"
      
    }    

    network_interfaces {
      network = "projects/${var.project_id}/global/networks/default"
      subnet  = "projects/${var.project_id}/regions/us-central1/subnetworks/default"
      
    }

    metadata = {
      terraform = "true"
      proxy-mode = "service_account"
    }

    tags = ["noaccelerator", "agentassistteam"]

  }

   
  labels = {
    applicationteam = "agentassist"
    environment = "development"
  }

  depends_on = [
        google_service_account_iam_member.users_access,
        
        
  ]
}


resource "google_service_account" "notebook_sa" {
  account_id    = "notebook-service-account" # Replace with your desired service account ID
  display_name  = "Notebook Service Account"
}

# Grant the service account permissions to access other Google Cloud resources (optional)
resource "google_project_iam_member" "gcs_access" {
  project = var.project_id # Replace with your project ID
  role    = "roles/storage.objectViewer" # Example role, grant roles as needed
  member  = "serviceAccount:${google_service_account.notebook_sa.email}"
}

# Grant users the iam.serviceAccounts.actAs permission on the service account
resource "google_service_account_iam_member" "users_access" {
  service_account_id = google_service_account.notebook_sa.name
  role               = "roles/iam.serviceAccountUser" # The role that grants iam.serviceAccounts.actAs
  member             = "user:kamarthi.pavan@gmail.com" # Replace with the user's email address
}
