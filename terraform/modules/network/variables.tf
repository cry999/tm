variable "region" {
  type = string
}

variable "common_tags" {
  type = map(string)
}

variable "prefixes" {
  type = list(string)
}

variable "vpc_cidr_first_2_block" {
  type = string
}
