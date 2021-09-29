resource "google_compute_firewall" "default" {
  name    = "http-firewall"
  network = google_compute_network.default.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8080"]
  }

  source_tags = ["web"]
}

resource "google_compute_network" "default" {
  name = "test-network"
}

resource "google_compute_address" "static" {
  name = "ipv4-address"
}

resource "google_compute_instance" "django_vm" {
  name         = "django"
  machine_type = "g1-small"
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

  # https://stackoverflow.com/questions/63577413/how-to-execute-scripts-remote-exec-under-google-cloud-container-optimized-os-u
  metadata_startup_script = "mkdir -p /home/${var.gce_ssh_user}/tmp/;sudo mount -t tmpfs -o size=100M tmpfs /home/${var.gce_ssh_user}/tmp/"
}

resource "null_resource" "code" {
  depends_on = [google_compute_instance.django_vm]
  connection {
    type        = "ssh"
    host        = google_compute_address.static.address
    private_key = file(var.gce_ssh_private_key)
    user        = var.gce_ssh_user
    script_path = "/home/${var.gce_ssh_user}/tmp/copy-code.sh"
  }

  # Need to modify the owner to copy the code. By default, terraform uses root. 
  provisioner "remote-exec" {
    inline = [
      "sudo chown -R ${var.gce_ssh_user}:${var.gce_ssh_user} /home/${var.gce_ssh_user}",
    ]
  }

  provisioner "file" {
    source      = "${abspath(path.module)}/../src"
    destination = "/home/${var.gce_ssh_user}"
  }
}

resource "null_resource" "provision" {
  depends_on = [null_resource.code]
  connection {
    type        = "ssh"
    host        = google_compute_address.static.address
    private_key = file(var.gce_ssh_private_key)
    user        = var.gce_ssh_user
    script_path = "/home/${var.gce_ssh_user}/tmp/provision.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "cd /home/${var.gce_ssh_user}/src",
      "export SECRET_KEY='${var.SECRET_KEY}'",
      # Run docker compose 
      # https://cloud.google.com/community/tutorials/docker-compose-on-container-optimized-os
      "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v \"$PWD:$PWD\" -w=\"$PWD\" docker/compose up"
    ]
  }
}
