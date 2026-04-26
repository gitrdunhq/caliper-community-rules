# Test fixtures for KIRBY-INF-025 / EEDOM-GCP-001 — GCP No Default Service Account
# PASS: google_compute_instance with an explicit service_account block
# FAIL: google_compute_instance with no service_account block (GCP uses the default Compute SA)

# --------------------------------------------------------------------------
# PASS cases
# --------------------------------------------------------------------------

# PASS: instance with a dedicated, minimally-scoped service account
resource "google_compute_instance" "pass_custom_sa" {
  name         = "pass-vm-custom-sa"
  machine_type = "n2-standard-2"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
  }

  service_account { # PASS: explicit service account — satisfies EEDOM-GCP-001
    email  = "my-app-sa@my-project.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }

  tags = ["web", "production"]
}

# PASS: instance with a service account and narrow scopes
resource "google_compute_instance" "pass_narrow_scopes" {
  name         = "pass-vm-narrow-scopes"
  machine_type = "e2-medium"
  zone         = "us-central1-b"

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }

  network_interface {
    network = "default"
  }

  service_account { # PASS: dedicated SA with minimal scopes
    email  = "gke-node-sa@my-project.iam.gserviceaccount.com"
    scopes = ["logging-write", "monitoring", "storage-ro"]
  }
}

# --------------------------------------------------------------------------
# FAIL cases
# --------------------------------------------------------------------------

# FAIL: no service_account block — GCP implicitly attaches the default Compute Engine SA
# which has project Editor permissions
resource "google_compute_instance" "fail_no_sa_block" {
  name         = "fail-vm-no-sa"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
  }

  # service_account block omitted — default -compute@developer.gserviceaccount.com used
  # violates least-privilege principle — fails EEDOM-GCP-001
}
