locals {
  name = "aws-websocket-example"
  author = "anouar"
  email = "kharrat-anwar@hotmail.com"
  lambda_memory = 128

  tags = {
    Name = "lambda_anouar_kharrat"
    GitRepo = "https://github.com/anwarkh"
    ManagedBy = "Terraform"
    Owner = "${local.email}"
  }
}