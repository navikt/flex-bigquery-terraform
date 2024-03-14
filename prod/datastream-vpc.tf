resource "google_compute_network" "flex_datastream_private_vpc" {
  name    = "flex-datastream-vpc"
  project = var.gcp_project["project"]
}

// The IP-range in the VPC used for the Datastream VPC peering. If a Cloud SQL instance is assigned a private
// IP address, this is the range it will be assigned from.
resource "google_compute_global_address" "flex_datastream_vpc_ip_range" {
  name          = "flex-datastream-vpc-ip-range"
  project       = var.gcp_project["project"]
  address_type  = "INTERNAL"
  purpose       = "VPC_PEERING"
  network       = google_compute_network.flex_datastream_private_vpc.id
  prefix_length = 20
}

// Private connectivity lets you create a peered configuration between your VPC and Datastream’s private network.
// A single configuration can be used by all streams and connection profiles within a single region.
resource "google_datastream_private_connection" "flex_datastream_private_connection" {
  location              = var.gcp_project["region"]
  display_name          = "flex-datastream-private-connection"
  private_connection_id = "flex-datastream-private-connection"

  vpc_peering_config {
    vpc    = google_compute_network.flex_datastream_private_vpc.id
    subnet = "10.1.0.0/29"
  }
}

// VPC Firewall rules control incoming or outgoing traffic to an instance. By default, incoming traffic from outside
// your network is blocked. Since we are using a Cloud SQL reverse proxy, we need to then create an ingress firewall
// rule that allows traffic on the source database port.
resource "google_compute_firewall" "allow_datastream_to_cloud_sql" {
  project = var.gcp_project["project"]
  name    = "allow-datastream-to-cloud-sql"
  network = google_compute_network.flex_datastream_private_vpc.name

  allow {
    protocol = "tcp"
    ports = [
      var.sykepengesoknad_cloud_sql_port,
      var.spinnsyn_cloud_sql_port,
      var.arkivering_oppgave_cloud_sql_port,
      var.sak_status_metrikk_cloud_sql_port,
      var.flexjar_cloud_sql_port,
      var.modia_kontakt_metrikk_cloud_sql_port,
      var.inntektsmelding_status_cloud_sql_port

    ]
  }

  source_ranges = [google_datastream_private_connection.flex_datastream_private_connection.vpc_peering_config.0.subnet]
}

data "google_sql_database_instance" "sykepengesoknad_db" {
  name = "sykepengesoknad"
}

data "google_sql_database_instance" "spinnsyn_db" {
  name = "spinnsyn-backend"
}

data "google_sql_database_instance" "arkivering_oppgave_db" {
  name = "sykepengesoknad-arkivering-oppgave"
}

data "google_sql_database_instance" "sak_status_metrikk_db" {
  name = "sykepengesoknad-sak-status-metrikk"
}

data "google_sql_database_instance" "flexjar_db" {
  name = "flexjar-backend"
}

data "google_sql_database_instance" "modia_kontakt_metrikk_db" {
  name = "flex-modia-kontakt-metrikk"
}

data "google_sql_database_instance" "flex_inntektsmelding_status_db" {
  name = "flex-inntektsmelding-status"
}

locals {
  proxy_instances = [
    "${data.google_sql_database_instance.sykepengesoknad_db.connection_name}=tcp:0.0.0.0:${var.sykepengesoknad_cloud_sql_port}",
    "${data.google_sql_database_instance.spinnsyn_db.connection_name}=tcp:0.0.0.0:${var.spinnsyn_cloud_sql_port}",
    "${data.google_sql_database_instance.arkivering_oppgave_db.connection_name}=tcp:0.0.0.0:${var.arkivering_oppgave_cloud_sql_port}",
    "${data.google_sql_database_instance.sak_status_metrikk_db.connection_name}=tcp:0.0.0.0:${var.sak_status_metrikk_cloud_sql_port}",
    "${data.google_sql_database_instance.flexjar_db.connection_name}=tcp:0.0.0.0:${var.flexjar_cloud_sql_port}",
    "${data.google_sql_database_instance.modia_kontakt_metrikk_db.connection_name}=tcp:0.0.0.0:${var.modia_kontakt_metrikk_cloud_sql_port}",
    "${data.google_sql_database_instance.flex_inntektsmelding_status_db.connection_name}=tcp:0.0.0.0:${var.inntektsmelding_status_cloud_sql_port}",

  ]
}

// This module handles the generation of metadata used to create an instance used to host containers on GCE.
// The module itself does not launch an instance or managed instance group.
module "cloud_sql_auth_proxy_container_datastream" {
  // https://endoflife.date/cos
  source         = "terraform-google-modules/container-vm/google"
  version        = "3.1.0"
  cos_image_name = "cos-101-17162-210-44"
  container = {
    // https://console.cloud.google.com/gcr/images/cloudsql-docker/EU/gce-proxy
    image   = "eu.gcr.io/cloudsql-docker/gce-proxy:1.33.8"
    command = ["/cloud_sql_proxy"]
    args = [
      "-instances=${join(",", local.proxy_instances)}",
      "-ip_address_types=PRIVATE"
    ]
  }
  restart_policy = "Always"
}

// Create a VM used to host the Cloud SQL reverse proxy.
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

// Datastream connection profile for BigQuery target. Can be used by multiple streams.
resource "google_datastream_connection_profile" "datastream_bigquery_connection_profile" {
  display_name          = "datastream-bigquery-connection-profile"
  location              = var.gcp_project["region"]
  connection_profile_id = "datastream-bigquery-connection-profile"

  bigquery_profile {}
}