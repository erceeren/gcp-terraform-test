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

variable "ssh_user" {
  default = "ssh_user"
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

output "private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}

output "public_key" {
  value     = tls_private_key.ssh_key.public_key_openssh
  sensitive = true
}

resource "google_compute_instance" "my_instance" {
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

  metadata = {
    ssh-keys               = "${var.ssh_user}:${tls_private_key.ssh_key.public_key_openssh}"
    block-project-ssh-keys = true
  }
}

output "instance_ip" {
  value = google_compute_instance.my_instance.network_interface[0].access_config[0].nat_ip
}

