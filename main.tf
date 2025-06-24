terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version =  "6.0"
    }
  }
}

provider "google" {
  region = var.region
}

# Enable APIs
module "enable" {
  source         = "./modules/enableapis"
  project_id     = var.project_id
 
}

# Trigger vertex AI work bench
module "vertexai_workbench" {
  source         = "./modules/vertexai_workbench"
  project_id     = var.project_id
  project_number = var.project_number
}