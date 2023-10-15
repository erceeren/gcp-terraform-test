terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.1.0"
    }
  }
}

provider "google" {
  project = "test-402112"
  region  = "europe-west2"
}


