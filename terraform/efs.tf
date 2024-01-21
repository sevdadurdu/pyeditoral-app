resource "aws_security_group" "efs_sg" {
  name        = "EFS Security Group"
  description = "Allow ECS to EFS communication"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 2049 # NFS port
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["34.207.51.8/32"]
  }
}

resource "aws_efs_file_system" "efs" {
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
}

resource "aws_efs_access_point" "app_access_point" {
  file_system_id = aws_efs_file_system.efs.id
  posix_user {
    uid = 1000
    gid = 1000
  }
  root_directory {
    path = "/efs"
    creation_info {
      owner_uid   = 1000
      owner_gid   = 1000
      permissions = "755"
    }
  }
}

resource "aws_efs_mount_target" "efs_mount" {
  count           = length(module.vpc.public_subnets)
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = module.vpc.public_subnets[count.index]
  security_groups = [aws_security_group.efs_sg.id]
}