resource "aws_db_subnet_group" "edu_eb_application_db_subnet_group" {
  name       = "edu_eb_application_db_subnet_group"
  subnet_ids = var.PRIVATE_SUBNET_IDS

  tags = {
    Name = "edu_eb_application_db_subnet_group"
  }
}

resource "aws_db_instance" "edu_eb_application_db" {
  allocated_storage    = 10
  db_name              = "edu_app"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = var.DB_USERNAME
  password             = var.DB_USERNAME
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.edu_eb_application_db_subnet_group.name
  multi_az             = false
  publicly_accessible  = false

  depends_on = [
    aws_db_subnet_group.edu_eb_application_db_subnet_group
  ]
}
