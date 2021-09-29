variable "project_id" {
  type        = string
  description = "The Google Cloud Project Id"
}

variable "region" {
  type    = string
  default = "us-west1"
}


variable "zone" {
  type    = string
  default = "us-west1-b"
}

variable "gce_ssh_user" {
  type        = string
  description = "GCE SSH User"
}

variable "gce_ssh_pub_key_file" {
  type        = string
  description = "GCE SSH User public key"
}

variable "gce_ssh_private_key" {
  type        = string
  description = "GCE SSH User public key"
}

variable "SECRET_KEY" {
  type        = string
  # https://docs.djangoproject.com/en/3.2/ref/settings/
  description = "Django Secret Key"
}