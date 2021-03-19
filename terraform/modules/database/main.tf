resource "aws_db_subnet_group" "mariadb" {
  name        = "${local.prefix_hyphen}-subnet-group"
  description = "Database subnet group for ${local.prefix_hyphen}"

  subnet_ids = var.subnet_ids

  tags = merge(var.common_tags, {
    "Name" = "${local.prefix_slash}/subnet-group"
  })
}

resource "aws_db_instance" "mariadb" {
  # ----------------
  #  Engine options
  # ----------------
  engine         = "mariadb"
  engine_version = "10.4.13"

  # ----------------------
  #  Basic configurations
  # ----------------------
  identifier = "${local.prefix_hyphen}-db"

  # auth
  username = var.root_user
  password = var.root_pass

  # ---------------
  #  Instance size
  # ---------------
  instance_class = "db.t2.micro"

  # ---------
  #  Storage
  # ---------
  storage_type          = "gp2"
  allocated_storage     = 20
  max_allocated_storage = 1000

  # -----------------------------
  #  Availability and durability
  # -----------------------------

  # not multi az

  # ------------
  #  Connection
  # ------------
  db_subnet_group_name   = aws_db_subnet_group.mariadb.name
  publicly_accessible    = false
  vpc_security_group_ids = [var.sg]
  availability_zone      = "ap-northeast-1a"

  # ------------
  #  Additional
  # ------------
  skip_final_snapshot         = true
  name                        = "tm"
  backup_retention_period     = 7
  copy_tags_to_snapshot       = true
  auto_minor_version_upgrade  = true
  allow_major_version_upgrade = true
}
