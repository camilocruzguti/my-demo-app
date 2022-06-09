variable "bucket_suffix" {
  type    = list(string)
  default = ["vpc"]
}

variable "bucket_base_name" {
  type    = string
  default = "cacruz-my-demo-app"
}

variable "bucket_count" {
  type    = number
  default = 1
}