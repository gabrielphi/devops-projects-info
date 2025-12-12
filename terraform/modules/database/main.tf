resource "mgc_dbaas_instances" "test_instance" {
  name                  = var.name
  user                  = var.user
  password              = var.password
  engine_name           = var.engine_name
  engine_version        = var.engine_version
  instance_type         = var.instance_type
  volume_size           = var.volume_size
  volume_type           = var.volume_type
  backup_retention_days = var.backup_retention_days
  backup_start_at       = var.backup_start_at
}