resource "aws_efs_file_system" "efs" {
  tags = map(
    "backup", "true"
  )
}

resource "aws_efs_mount_target" "a" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = var.private_subnet_ids[0]
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "b" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = var.private_subnet_ids[1]
  security_groups = [aws_security_group.efs.id]
}