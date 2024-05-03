data "google_sql_database_instance" "cloud_sql_instance" {
  name = "flex-datastream-test"
}

// You can configure a virtual machine (VM) instance or an instance template to deploy and launch a Docker container.
// This Google-provided module handles the generation of metadata for deploying containers on GCE instances.
module "flex_test_cloud_sql_auth_proxy_container_datastream" {
  source         = "terraform-google-modules/container-vm/google"
  version        = "3.1.1"
  cos_image_name = "cos-101-17162-386-65"
  container = {
    // https://github.com/GoogleCloudPlatform/cloud-sql-proxy/releases
    image   = "eu.gcr.io/cloudsql-docker/gce-proxy:1.35.1"
    command = ["/cloud_sql_proxy"]
    args = [
      "-instances=${data.google_sql_database_instance.cloud_sql_instance.connection_name}=tcp:0.0.0.0:${var.flex_datastream_test_cloud_sql_port}",
    ]
  }
  restart_policy = "Always"
}

resource "google_compute_instance" "cloud_sql_auth_proxy_compute_instance" {
  name = "flex-datastream-test-cloud-sql-auth-proxy"
  // Small machine type with 0.5 vCPU and 2 GB of memory, backed by a shared physical core.
  machine_type              = "e2-small"
  project                   = var.gcp_project["project"]
  zone                      = var.gcp_project["zone"]
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = module.flex_test_cloud_sql_auth_proxy_container_datastream.source_image
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
    gce-container-declaration = module.flex_test_cloud_sql_auth_proxy_container_datastream.metadata_value
  }

  labels = {
    container-vm = module.cloud_sql_auth_proxy_container_datastream.vm_container_label
  }
}
