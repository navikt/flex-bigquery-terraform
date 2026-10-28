resource "google_storage_bucket" "bucket" {
  name          = var.name
  location      = var.location
  storage_class = var.storage_class
  force_destroy = var.force_destroy
  uniform_bucket_level_access = true

  versioning {
    enabled = var.versioning
  }
}