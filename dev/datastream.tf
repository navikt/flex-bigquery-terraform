resource "google_compute_network" "flex_datastream_private_vpc" {
  name    = "flex-datastream-vpc"
  project = var.gcp_project["project"]
}

data "google_sql_database_instance" "sykepengesoknad_db" {
  name = "sykepengesoknad"
}

data "google_secret_manager_secret_version" "sykepengesoknad_datastream_secret" {
  secret = var.sykepengesoknad_datastream_secret
}

locals {
  sykepengesoknad_datastream_credentials = jsondecode(
    data.google_secret_manager_secret_version.sykepengesoknad_datastream_secret.secret_data
  )
}

// TODO:  Sjekk om det er mulig å definere "flex-datastream-vpc-ip-range" tilhørende VPC her.

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

// VPX Firewall rules control incoming or outgoing traffic to an instance. By default, incoming traffic from outside
// your network is blocked. Since we are using a Cloud SQL reverse proxy, we need to then create an ingress firewall
// rule that allows traffic on the source database port.
resource "google_compute_firewall" "allow_datastream_to_cloud_sql" {
  project = var.gcp_project["project"]
  name    = "allow-datastream-to-cloud-sql"
  network = google_compute_network.flex_datastream_private_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  source_ranges = [google_datastream_private_connection.flex_datastream_private_connection.vpc_peering_config.0.subnet]
}