resource "google_storage_bucket" "bucket" {
  name          = var.name
  location      = var.location
  storage_class = var.storage_class

  versioning {
    enabled = var.versioning
  }
}