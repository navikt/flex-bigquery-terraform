resource "google_storage_bucket" "terraform" {
  name          = var.name
  location      = var.location
  storage_class = var.storage_class

  versioning {
    enabled = var.versioning
  }
}