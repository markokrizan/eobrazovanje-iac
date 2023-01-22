variable "PUBLIC_SUBNET_IDS" {
  type    = list(string)
  default = ["subnet-085f62afac3a140e5", "subnet-0d0aa79ed0c83ad5b"]
}

variable "PRIVATE_SUBNET_IDS" {
  type    = list(string)
  default = ["subnet-0e8cb586c3bece9e7", "subnet-0b6eca88b6634d159"]
}

variable "ACCESS_KEY_PAIR_NAME" {
  default = "edu-app-access-key"
}

# TODO
# variable "SSL_CERTIFICATE_ARN" {
#     default = "arn:aws:acm:eu-west-2:517751871049:certificate/8e43a8cd-1cd9-4078-bea5-074b771ac0da"
# }
