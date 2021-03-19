data "aws_ssm_parameter" "db_root_user" {
  name = "/${var.service}/${var.env}/mysql/root_user"
}

data "aws_ssm_parameter" "db_root_pass" {
  name = "/${var.service}/${var.env}/mysql/root_pass"
}
