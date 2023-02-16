resource "google_compute_network" "flex_datastream_private_vpc" {
  name = "flex-datastream-vpc"
  project =  var.gcp_project["project"]
}