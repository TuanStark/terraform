variable "environment" {
  type    = string
  default = "dev"
}

variable "bucket_suffix" {
  type    = list(string)
  default = ["media", "logs", "backups"]
}
