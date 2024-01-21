################################################################################
# RDS Security Group
################################################################################

module "postgresql_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/postgresql"
  version = "5.1.0"

  name                = local.name
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = ["34.207.51.8/32"]
  tags                = local.tags
}

################################################################################
# RDS Module
################################################################################

module "postgresql" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.3.1"

  identifier = local.name

  engine               = "postgres"
  engine_version       = "14"
  family               = "postgres14"
  major_engine_version = "14"
  instance_class       = "db.t3.micro"

  allocated_storage = 20

  db_name                     = "PyEditoral"
  manage_master_user_password = true
  username                    = "root"
  password                    = data.aws_ssm_parameter.db_root_password.value
  port                        = 5432

  multi_az            = false
  publicly_accessible = true

  # DB subnet group
  create_db_subnet_group      = true
  subnet_ids                  = module.vpc.private_subnets
  db_subnet_group_description = "Database subnet group for pyeditoral"

  vpc_security_group_ids = [module.postgresql_security_group.security_group_id]

  maintenance_window          = "Mon:00:00-Mon:03:00"
  backup_window               = "03:00-06:00"
  create_cloudwatch_log_group = false

  backup_retention_period = 1
  skip_final_snapshot     = false
  deletion_protection     = true

  performance_insights_enabled = false

  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]

  tags = local.tags
  db_option_group_tags = {
    "Sensitive" = "low"
  }
  db_parameter_group_tags = {
    "Sensitive" = "low"
  }
}

################################################################################
# RDS Domain Record
################################################################################

resource "aws_route53_record" "postgres" {
  zone_id = local.zone_id
  name    = "pyeditoraldb"
  type    = "CNAME"
  ttl     = 300
  records = ["pyeditoral.ctwsoqsuouq6.eu-west-1.rds.amazonaws.com"]
}