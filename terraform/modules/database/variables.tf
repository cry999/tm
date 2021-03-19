variable "prefixes" {
  type = list(string)
}

variable "common_tags" {
  type = map(string)
}

variable "root_user" {
  type      = string
  sensitive = true
}

variable "root_pass" {
  type      = string
  sensitive = true
}

variable "subnet_ids" {
  type = list(string)
}

variable "sg" {
  type = string
}
