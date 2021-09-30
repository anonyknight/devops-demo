resource "google_compute_firewall" "http-server" {
  name    = "default-allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "8000", "8080"]
  }

  // Allow traffic from everywhere to instances with an http-server tag
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}


resource "google_compute_address" "static" {
  name = "ipv4-address"
}

resource "google_compute_instance" "docs" {
  name         = "docs"
  machine_type = "g1-small"
  zone         = var.zone

  tags = ["http-server"]

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
    ssh-keys = "${var.gce_ssh_user}:${var.gce_ssh_pub_key}"
  }

  # https://stackoverflow.com/questions/63577413/how-to-execute-scripts-remote-exec-under-google-cloud-container-optimized-os-u
  metadata_startup_script = "mkdir -p /home/${var.gce_ssh_user}/tmp/;sudo mount -t tmpfs -o size=100M tmpfs /home/${var.gce_ssh_user}/tmp/"
}

resource "null_resource" "code" {
  depends_on = [google_compute_instance.docs]
  connection {
    type        = "ssh"
    host        = google_compute_address.static.address
    private_key = var.gce_ssh_private_key
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
    private_key = var.gce_ssh_private_key
    user        = var.gce_ssh_user
    script_path = "/home/${var.gce_ssh_user}/tmp/provision.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "cd /home/${var.gce_ssh_user}/src",
      # Run docker compose 
      # https://cloud.google.com/community/tutorials/docker-compose-on-container-optimized-os
      "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v \"$PWD:$PWD\" -w=\"$PWD\" docker/compose build",
      "docker run -d --rm -v /var/run/docker.sock:/var/run/docker.sock -v \"$PWD:$PWD\" -w=\"$PWD\" docker/compose up"
    ]
  }
}
