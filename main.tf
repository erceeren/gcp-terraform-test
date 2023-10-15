terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.1.0"
    }
  }
}

terraform {
  backend "gcs" {
    bucket = "shooter-terraform-backend"
    prefix = "prod"
  }
}

provider "google" {
  project = "shooter-game-400216"
  region  = "europe-west2"
}


resource "google_service_account" "default" {
  account_id   = "my-custom-sa"
  display_name = "Custom SA for VM Instance"
}

resource "google_compute_instance" "default" {
  name         = "test-instance"
  machine_type = "n2-standard-2"
  zone         = "europe-west2-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "NVME"
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}

