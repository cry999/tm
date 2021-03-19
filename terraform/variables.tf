variable "env" {
  default = "prd"
}

variable "service" {
  default = "tm"
}

variable "common_tags" {
  default = {
    "Environment" = "prd"
    "Service"     = "TM"
  }
}

variable "vpc_cidr_first_2_block" {
  default = "10.192"
}
