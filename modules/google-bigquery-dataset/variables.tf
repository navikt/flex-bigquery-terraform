variable "location" {
  description = "The resource location."
  type        = string
}

variable "dataset_id" {
  description = "The dataset identifier."
  type        = string
}

variable "dataset_iam_member" {
  description = "The email identifying the automatically created service account used to access the dataset."
  type        = string
}