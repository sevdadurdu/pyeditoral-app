data "aws_ssm_parameter" "db_root_password" {
  name            = "/rds/db.root.password"
  with_decryption = true
}

data "aws_ssm_parameter" "app_secret_key" {
  name            = "/prod/app.secret.key"
  with_decryption = true
}