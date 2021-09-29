resource "google_compute_instance" "default" {
  name         = "django"
  machine_type = "f1-micro"
  zone         = "us-central1-a"

  tags = ["django"]

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-81-12871-103-0"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    user-data = file("my_cloud_init.conf")
  }

  # metadata_startup_script = "echo hi > /test.txt"
}