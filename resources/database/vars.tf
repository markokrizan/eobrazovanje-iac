variable "PRIVATE_SUBNET_IDS" {
  type    = list(string)
  default = ["subnet-0e8cb586c3bece9e7", "subnet-0b6eca88b6634d159"]
}

variable "DB_USERNAME" {
  description = "Database administrator username"
  type        = string
  sensitive   = true
}

variable "DB_PASSWORD" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}
