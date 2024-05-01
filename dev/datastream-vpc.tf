resource "google_compute_network" "flex_datastream_private_vpc" {
  name    = "flex-datastream-vpc"
  project = var.gcp_project["project"]
}

// Defines the IP range in the VPC that will be used to assign Private IPs to Cloud SQL instances.
// This IP range is managed by Google and is made available in our VPC through Private Services Access.
resource "google_compute_global_address" "flex_datastream_vpc_ip_range" {
  name          = "flex-datastream-vpc-ip-range"
  project       = var.gcp_project["project"]
  address_type  = "INTERNAL"
  purpose       = "VPC_PEERING"
  network       = google_compute_network.flex_datastream_private_vpc.id
  prefix_length = 20
}

// Creates a peered configuration between our VPC and Datastream’s private network.
resource "google_datastream_private_connection" "flex_datastream_private_connection" {
  location              = var.gcp_project["region"]
  display_name          = "flex-datastream-private-connection"
  private_connection_id = "flex-datastream-private-connection"

  vpc_peering_config {
    // Specifies the VPC that the Datastream VPC will peer with.
    vpc = google_compute_network.flex_datastream_private_vpc.id
    // Defines an available IP range in the Datastream VPC for Datastream to create a subnet.
    // This subnet exists in the Google-managed Datastream VPC.
    subnet = "10.1.0.0/29"
  }
}

// Use to define the VPC firewall rules that controls traffic to the resouces in our VPC. By default, incoming traffic
// from outside your network is blocked. Since we are using a Cloud SQL reverse proxy, we need to create an ingress
// firewall rule that allows traffic from the Datastream VPC IP range to the Cloud SQL instance on the specified port.
resource "google_compute_firewall" "allow_datastream_to_cloud_sql" {
  project = var.gcp_project["project"]
  name    = "allow-datastream-to-cloud-sql"
  network = google_compute_network.flex_datastream_private_vpc.name

  allow {
    protocol = "tcp"
    ports    = [var.spinnsyn_cloud_sql_port, ]
  }

  source_ranges = [google_datastream_private_connection.flex_datastream_private_connection.vpc_peering_config.0.subnet]
}

data "google_sql_database_instance" "spinnsyn_db" {
  name = "spinnsyn-backend"
}

// You can configure a virtual machine (VM) instance or an instance template to deploy and launch a Docker container.
// This Googe-provided module handles the generation of metadata for deploying containers on GCE instances.
module "cloud_sql_auth_proxy_container_datastream" {
  source         = "terraform-google-modules/container-vm/google"
  version        = "3.1.1"
  cos_image_name = "cos-101-17162-386-65"
  container = {
    // https://github.com/GoogleCloudPlatform/cloud-sql-proxy/releases
    image   = "eu.gcr.io/cloudsql-docker/gce-proxy:1.35.1"
    command = ["/cloud_sql_proxy"]
    args = [
      "-instances=${data.google_sql_database_instance.spinnsyn_db.connection_name}=tcp:0.0.0.0:${var.spinnsyn_cloud_sql_port}",
      "-ip_address_types=PRIVATE"
    ]
  }
  restart_policy = "Always"
}

resource "google_compute_instance" "flex_datastream_cloud_sql_proxy_vm" {
  name = "flex-datastream-cloud-sql-proxy-vm"
  // Medium machine type with 1 vCPU and 4 GB of memory, backed by a shared physical core.
  machine_type = "e2-medium"
  project      = var.gcp_project["project"]
  zone         = var.gcp_project["zone"]

  boot_disk {
    initialize_params {
      image = module.cloud_sql_auth_proxy_container_datastream.source_image
    }
  }

  network_interface {
    network = google_compute_network.flex_datastream_private_vpc.name
    // Ensures that a Private IP is assigned to the VM.
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  metadata = {
    gce-container-declaration = module.cloud_sql_auth_proxy_container_datastream.metadata_value
    google-logging-enabled    = "true"
    google-monitoring-enabled = "true"
  }

  labels = {
    container-vm = module.cloud_sql_auth_proxy_container_datastream.vm_container_label
  }
}

// Defines a Datastream connection profile for a BigQuery target.
// This profile can be used by multiple streams to connect to BigQuery.
resource "google_datastream_connection_profile" "datastream_bigquery_connection_profile" {
  display_name          = "datastream-bigquery-connection-profile"
  location              = var.gcp_project["region"]
  connection_profile_id = "datastream-bigquery-connection-profile"

  bigquery_profile {}
}

