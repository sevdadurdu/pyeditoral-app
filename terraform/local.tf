data "aws_availability_zones" "available" {}

locals {
  name     = "pyeditoral"
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
  tags = {
    Name       = local.name
    managed-by = "terraform"
  }

  zone_id = "Z09833561H1V8N0DHNPHX"

  ecs_cluster_name = "pyeditoral"
}