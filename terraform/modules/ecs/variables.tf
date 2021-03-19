variable "region" {
  type = string
}

variable "common_tags" {
  type = map(string)
}

variable "prefixes" {
  type = list(string)
}

variable "template_dir" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "service_sg" {
  type = string
}

variable "mysql_host" {
  type = string
}

variable "mysql_port" {
  type = number
}
