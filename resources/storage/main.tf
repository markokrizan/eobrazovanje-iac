variable "name" {
  type = string
}

resource "aws_s3_bucket" "storage-bucket" {
  bucket = var.name
  acl    = "private"

  tags = {
    Name = var.name
  }
}
