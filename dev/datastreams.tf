locals {
  datastream_vpc_resources = {
    vpc_name                       = google_compute_network.flex_datastream_private_vpc.name
    private_connection_id          = google_datastream_private_connection.flex_datastream_private_connection.id
    bigquery_connection_profile_id = google_datastream_connection_profile.datastream_bigquery_connection_profile.id
  }
}

module "spinnsyn_datastream" {
  source                                       = "git::https://github.com/navikt/terraform-google-bigquery-datastream.git?ref=v1.0.4"
  gcp_project                                  = var.gcp_project
  application_name                             = "spinnsyn"
  cloud_sql_instance_name                      = "spinnsyn-backend"
  cloud_sql_instance_db_name                   = "spinnsyn-db"
  cloud_sql_instance_db_credentials            = local.spinnsyn_datastream_credentials
  datastream_vpc_resources                     = local.datastream_vpc_resources
  big_query_dataset_delete_contents_on_destroy = true
  postgresql_exclude_schemas = [
    { schema = "public", tables = [{ table = "flyway_schema_history" }, { table = "annullering" }] }
  ]
}

module "spinnsyn_arkivering_datastream" {
  source                                       = "git::https://github.com/navikt/terraform-google-bigquery-datastream.git?ref=v1.0.4"
  gcp_project                                  = var.gcp_project
  application_name                             = "spinnsyn-arkivering"
  cloud_sql_instance_name                      = "spinnsyn-arkivering"
  cloud_sql_instance_db_name                   = "spinnsyn-arkivering-db"
  cloud_sql_instance_db_credentials            = local.spinnsyn_arkivering_datastream_credentials
  datastream_vpc_resources                     = local.datastream_vpc_resources
  big_query_dataset_delete_contents_on_destroy = true
}

module "flex_arbeidssokerregister_oppdatering_datastream" {
  source                                       = "git::https://github.com/navikt/terraform-google-bigquery-datastream.git?ref=v1.0.4"
  gcp_project                                  = var.gcp_project
  application_name                             = "flex-arbeidssokerregister-oppdatering"
  cloud_sql_instance_name                      = "flex-arbeidssokerregister-oppdatering"
  cloud_sql_instance_db_name                   = "flex-arbeidssokerregister-oppdatering-db"
  cloud_sql_instance_db_credentials            = local.flex_arbeidssokerregister_oppdatering_credentials
  datastream_vpc_resources                     = local.datastream_vpc_resources
  big_query_dataset_delete_contents_on_destroy = true

}


module "flex_sykmeldinger_backend_datastream" {
  source                                       = "git::https://github.com/navikt/terraform-google-bigquery-datastream.git?ref=v1.0.4"
  gcp_project                                  = var.gcp_project
  application_name                             = "flex-sykmeldinger-backend"
  cloud_sql_instance_name                      = "flex-sykmeldinger-backend"
  cloud_sql_instance_db_name                   = "flex-sykmeldinger-backend-db"
  cloud_sql_instance_db_credentials            = local.flex_sykmeldinger_datastream_backend_credentials
  datastream_vpc_resources                     = local.datastream_vpc_resources
  big_query_dataset_delete_contents_on_destroy = true

}
