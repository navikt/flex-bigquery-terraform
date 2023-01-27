data "google_secret_manager_secret_version" "sykepengesoknad_sak_status_bigquery_secret" {
  secret = var.sykepengesoknad_sak_status_bigquery_secret
}

locals {
  sak_status_metrikk_db = jsondecode(
    data.google_secret_manager_secret_version.sykepengesoknad_sak_status_bigquery_secret.secret_data
  )
}

module "sykepengesoknad_sak-status-metrikk-bigquery_connection" {
  source = "../modules/google-bigquery-connection"

  connection_id = "sykepengesoknad-sak-status-metrikk"
  location      = var.gcp_project["region"]
  instance_id   = "${var.gcp_project["project"]}:${var.gcp_project["region"]}:sykepengesoknad-sak-status-metrikk"
  database      = "sykepengesoknad-sak-status-metrikk-db"
  username      = local.sak_status_metrikk_db.username
  password      = local.sak_status_metrikk_db.password
}

module "sykepengesoknad_sak_status_metrikk_sykepengesoknad_id" {
  source = "../modules/google-bigquery-table"

  deletion_protection = false
  location            = var.gcp_project["region"]
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  table_id            = "sykepengesoknad_sak_status_metrikk_sykepengesoknad_id"
  table_schema = jsonencode(
    [
      {
        mode = "NULLABLE"
        name = "sykepengesoknad_uuid"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "sykepengesoknad_at_id"
        type = "STRING"
      },
    ]
  )

  data_transfer_display_name      = "sykepengesoknad_sak_status_metrikk_sykepengesoknad_id_query"
  data_transfer_schedule          = "every day 02:00"
  data_transfer_service_account   = "federated-query@${var.gcp_project["project"]}.iam.gserviceaccount.com"
  data_transfer_start_time        = "2023-01-23T00:00:00Z"
  data_transfer_destination_table = module.sykepengesoknad_sak_status_metrikk_sykepengesoknad_id.bigquery_table_id
  data_transfer_mode              = "WRITE_TRUNCATE"

  data_transfer_query = <<EOF
SELECT * FROM
EXTERNAL_QUERY('${var.gcp_project["project"]}.${var.gcp_project["region"]}.sykepengesoknad-sak-status-metrikk',
'SELECT sykepengesoknad_uuid, sykepengesoknad_at_id FROM sykepengesoknad_id');
EOF

}

module "sykepengesoknad_sak_status_metrikk_sykepengesoknad_vedtaksperiode" {
  source = "../modules/google-bigquery-table"

  deletion_protection = false
  location            = var.gcp_project["region"]
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  table_id            = "sykepengesoknad_sak_status_metrikk_sykepengesoknad_vedtaksperiode"
  table_schema = jsonencode(
    [
      {
        mode = "NULLABLE"
        name = "sykepengesoknad_at_id"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "vedtaksperiode_id"
        type = "STRING"
      },
    ]
  )

  data_transfer_display_name      = "sykepengesoknad_sak_status_metrikk_sykepengesoknad_vedtaksperiode_query"
  data_transfer_schedule          = "every day 02:00"
  data_transfer_service_account   = "federated-query@${var.gcp_project["project"]}.iam.gserviceaccount.com"
  data_transfer_start_time        = "2023-01-23T00:00:00Z"
  data_transfer_destination_table = module.sykepengesoknad_sak_status_metrikk_sykepengesoknad_vedtaksperiode.bigquery_table_id
  data_transfer_mode              = "WRITE_TRUNCATE"

  data_transfer_query = <<EOF
SELECT * FROM
EXTERNAL_QUERY('${var.gcp_project["project"]}.${var.gcp_project["region"]}.sykepengesoknad-sak-status-metrikk',
'SELECT sykepengesoknad_at_id, vedtaksperiode_id FROM sykepengesoknad_vedtaksperiode');
EOF

}

module "sykepengesoknad_sak_status_metrikk_vedtaksperiode_forkastet" {
  source = "../modules/google-bigquery-table"

  deletion_protection = false
  location            = var.gcp_project["region"]
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  table_id            = "sykepengesoknad_sak_status_metrikk_vedtaksperiode_forkastet"
  table_schema = jsonencode(
    [
      {
        mode = "NULLABLE"
        name = "vedtaksperiode_id"
        type = "STRING"
      }
    ]
  )

  data_transfer_display_name      = "sykepengesoknad_sak_status_metrikk_vedtaksperiode_forkastet_query"
  data_transfer_schedule          = "every day 02:00"
  data_transfer_service_account   = "federated-query@${var.gcp_project["project"]}.iam.gserviceaccount.com"
  data_transfer_start_time        = "2023-01-23T00:00:00Z"
  data_transfer_destination_table = module.sykepengesoknad_sak_status_metrikk_vedtaksperiode_forkastet.bigquery_table_id
  data_transfer_mode              = "WRITE_TRUNCATE"

  data_transfer_query = <<EOF
SELECT * FROM
EXTERNAL_QUERY('${var.gcp_project["project"]}.${var.gcp_project["region"]}.sykepengesoknad-sak-status-metrikk',
'SELECT vedtaksperiode_id FROM vedtaksperiode_forkastet');
EOF

}

module "sykepengesoknad_sak_status_metrikk_vedtaksperiode_funksjonell_feil" {
  source = "../modules/google-bigquery-table"

  deletion_protection = false
  location            = var.gcp_project["region"]
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  table_id            = "sykepengesoknad_sak_status_metrikk_vedtaksperiode_funksjonell_feil"
  table_schema = jsonencode(
    [
      {
        mode = "NULLABLE"
        name = "id"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "vedtaksperiode_id"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "melding"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "tidspunkt"
        type = "TIMESTAMP"
      },
    ]
  )

  data_transfer_display_name      = "sykepengesoknad_sak_status_metrikk_vedtaksperiode_funksjonell_feil_query"
  data_transfer_schedule          = "every day 02:00"
  data_transfer_service_account   = "federated-query@${var.gcp_project["project"]}.iam.gserviceaccount.com"
  data_transfer_start_time        = "2023-01-23T00:00:00Z"
  data_transfer_destination_table = module.sykepengesoknad_sak_status_metrikk_vedtaksperiode_funksjonell_feil.bigquery_table_id
  data_transfer_mode              = "WRITE_TRUNCATE"

  data_transfer_query = <<EOF
SELECT * FROM
EXTERNAL_QUERY('${var.gcp_project["project"]}.${var.gcp_project["region"]}.sykepengesoknad-sak-status-metrikk',
'SELECT id, vedtaksperiode_id, melding, tidspunkt FROM vedtaksperiode_funksjonell_feil');
EOF

}

module "sykepengesoknad_sak_status_metrikk_vedtaksperiode_tilstand" {
  source = "../modules/google-bigquery-table"

  deletion_protection = false
  location            = var.gcp_project["region"]
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  table_id            = "sykepengesoknad_sak_status_metrikk_vedtaksperiode_tilstand"
  table_schema = jsonencode(
    [
      {
        mode = "NULLABLE"
        name = "id"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "vedtaksperiode_id"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "tilstand"
        type = "STRING"
      },
      {
        mode = "NULLABLE"
        name = "tidspunkt"
        type = "TIMESTAMP"
      },
    ]
  )

  data_transfer_display_name      = "sykepengesoknad_sak_status_metrikk_vedtaksperiode_tilstand_query"
  data_transfer_schedule          = "every day 02:00"
  data_transfer_service_account   = "federated-query@${var.gcp_project["project"]}.iam.gserviceaccount.com"
  data_transfer_start_time        = "2023-01-23T00:00:00Z"
  data_transfer_destination_table = module.sykepengesoknad_sak_status_metrikk_vedtaksperiode_tilstand.bigquery_table_id
  data_transfer_mode              = "WRITE_TRUNCATE"

  data_transfer_query = <<EOF
SELECT * FROM
EXTERNAL_QUERY('${var.gcp_project["project"]}.${var.gcp_project["region"]}.sykepengesoknad-sak-status-metrikk',
'SELECT id, vedtaksperiode_id, tilstand, tidspunkt FROM vedtaksperiode_tilstand');
EOF

}

module "sykepengesoknad_sak_status_metrikk_tilstand_view" {
  source = "../modules/google-bigquery-view"

  deletion_protection = false
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  view_id             = "sykepengesoknad_sak_status_metrikk_tilstand_view"
  view_schema = jsonencode(
    [
      {
        mode        = "NULLABLE"
        name        = "sykepengesoknad_uuid"
        type        = "STRING"
        description = "Unik ID for sykepengesøknaden opprettet av Team Flex."
      },
      {
        mode        = "NULLABLE"
        name        = "sykepengesoknad_at_id"
        type        = "STRING"
        description = "Unik ID for sykepengesøknaden opprettet av Bømlo."
      },
      {
        mode        = "NULLABLE"
        name        = "vedtaksperiode_id"
        type        = "STRING"
        description = "Unik ID for vedtaksperiode opprettet av Bømlo."
      },
      {
        mode        = "NULLABLE"
        name        = "tilstand"
        type        = "STRING"
        description = "Tilstand i vedtaksperiodens tilstandshistorikk."
      },
      {
        mode        = "NULLABLE"
        name        = "tidspunkt"
        type        = "TIMESTAMP"
        description = "Tildpunktet tilstanden ble opprettet."
      }
    ]
  )

  view_query = <<EOF
SELECT a.sykepengesoknad_uuid, a.sykepengesoknad_at_id, c.vedtaksperiode_id, c.tilstand, c.tidspunkt
FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.${module.sykepengesoknad_sak_status_metrikk_sykepengesoknad_id.bigquery_table_id}` a
  INNER JOIN `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.${module.sykepengesoknad_sak_status_metrikk_sykepengesoknad_vedtaksperiode.bigquery_table_id}` b ON b.sykepengesoknad_at_id = a.sykepengesoknad_at_id
  INNER JOIN `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.${module.sykepengesoknad_sak_status_metrikk_vedtaksperiode_tilstand.bigquery_table_id}` c on c.vedtaksperiode_id = b.vedtaksperiode_id
EOF

}

module "sykepengesoknad_sak_status_metrikk_siste_tilstand_view" {
  source = "../modules/google-bigquery-view"

  deletion_protection = false
  dataset_id          = google_bigquery_dataset.flex_dataset.dataset_id
  view_id             = "sykepengesoknad_sak_status_metrikk_siste_tilstand_view"
  view_schema = jsonencode(
    [
      {
        mode        = "NULLABLE"
        name        = "sykepengesoknad_uuid"
        type        = "STRING"
        description = "Unik ID for sykepengesøknaden opprettet av Team Flex."
      },
      {
        mode        = "NULLABLE"
        name        = "sykepengesoknad_at_id"
        type        = "STRING"
        description = "Unik ID for sykepengesøknaden opprettet av Bømlo."
      },
      {
        mode        = "NULLABLE"
        name        = "vedtaksperiode_id"
        type        = "STRING"
        description = "Unik ID for vedtaksperiode opprettet av Bømlo."
      },
      {
        mode        = "NULLABLE"
        name        = "tilstand"
        type        = "STRING"
        description = "Tilstand i vedtaksperiodens tilstandshistorikk."
      },
      {
        mode        = "NULLABLE"
        name        = "tidspunkt"
        type        = "TIMESTAMP"
        description = "Tildpunktet tilstanden ble opprettet."
      },
      {
        mode        = "NULLABLE"
        name        = "funksjonell_feil"
        type        = "STRING"
        description = "Alle distincte funksjonelle feil concatet med komma."
      },
      {
        mode        = "NULLABLE"
        name        = "forkastet"
        type        = "BOOLEAN"
        description = "Om vedtaksperioden er forkastet."
      }
    ]
  )

  view_query = <<EOF
SELECT a.sykepengesoknad_uuid, a.sykepengesoknad_at_id, c.vedtaksperiode_id, c.tilstand, c.tidspunkt, f.funksjonell_feil, IFNULL(t.forkastet, false) forkastet
FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.${module.sykepengesoknad_sak_status_metrikk_sykepengesoknad_id.bigquery_table_id}` a
  INNER JOIN `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.${module.sykepengesoknad_sak_status_metrikk_sykepengesoknad_vedtaksperiode.bigquery_table_id}` b ON b.sykepengesoknad_at_id = a.sykepengesoknad_at_id
  INNER JOIN `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.${module.sykepengesoknad_sak_status_metrikk_vedtaksperiode_tilstand.bigquery_table_id}` c on c.vedtaksperiode_id = b.vedtaksperiode_id
  INNER JOIN (
    SELECT vedtaksperiode_id, max(tidspunkt) AS tidspunkt
    FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.${module.sykepengesoknad_sak_status_metrikk_vedtaksperiode_tilstand.bigquery_table_id}`
    GROUP BY vedtaksperiode_id
  ) d ON c.vedtaksperiode_id = d.vedtaksperiode_id AND d.tidspunkt = c.tidspunkt
  LEFT OUTER JOIN (SELECT vedtaksperiode_id,
                         string_agg(distinct melding, "," order by melding) funksjonell_feil
                   FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.${module.sykepengesoknad_sak_status_metrikk_vedtaksperiode_funksjonell_feil.bigquery_table_id}`
                   group by vedtaksperiode_id) f on f.vedtaksperiode_id = b.vedtaksperiode_id
  LEFT OUTER JOIN (SELECT vedtaksperiode_id, true forkastet
                   FROM `${var.gcp_project["project"]}.${google_bigquery_dataset.flex_dataset.dataset_id}.${module.sykepengesoknad_sak_status_metrikk_vedtaksperiode_forkastet.bigquery_table_id}`
                   group by vedtaksperiode_id) t on t.vedtaksperiode_id = b.vedtaksperiode_id
EOF

}
