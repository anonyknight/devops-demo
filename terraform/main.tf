resource "google_compute_address" "static" {
  name = "ipv4-address"
}

resource "google_compute_instance" "django_vm" {
  name         = "django"
  machine_type = "f1-micro"
  zone         = var.zone

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
      nat_ip = google_compute_address.static.address
    }
  }

  metadata = {
    # user-data = file("my_cloud_init.conf")
    ssh-keys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }

  # metadata_startup_script = "echo hi > /test.txt"
}

resource "null_resource" "code" {
  depends_on = [google_compute_instance.django_vm]
  connection {
    type        = "ssh"
    host        = google_compute_address.static.address
    private_key = var.gce_ssh_private_key
    user        = var.gce_ssh_user
    port        = "22"
    agent       = false
  }

  provisioner "file" {
    source      = "."
    destination = "~"
  }
  provisioner "remote-exec" {
    inline = [
      "ls -al",
    ]
  }
}
