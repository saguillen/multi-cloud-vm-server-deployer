provider "google" {
  project = "your-project-id"
  region  = "us-central1"
  zone    = "us-central1-a"
}

resource "google_compute_firewall" "http" {
  name    = "allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

resource "google_compute_instance" "web" {
  name         = "web-server-gcp"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  tags = ["http-server"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y apache2
    systemctl start apache2
    systemctl enable apache2
    echo "<h1>Hello from GCP Compute Engine via Terraform</h1>" > /var/www/html/index.html
  EOF
}

output "public_ip" {
  value = google_compute_instance.web.network_interface[0].access_config[0].nat_ip
}