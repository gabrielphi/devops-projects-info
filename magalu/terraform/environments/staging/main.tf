module "database" {
  source = "../../modules/database"
  name   = "test-instance"
  user   = "dbadmin"
  password = "examplepassword"
  engine_name = "postgresql"
  engine_version = "16"
  instance_type = "BV2-4-10"
  volume_size = 10
  volume_type = "CLOUD_NVME15K"
  backup_start_at = "16:00:00"
  backup_retention_days = 1
}
module "vm" {
  source = "../../modules/vm"
  
  providers = {
    mgc.nordeste = mgc.nordeste
  }
  
  instances = {
    "vm-1" = {
      name                = "test-vm-1"
      machine_type        = "BV2-2-20"
      image               = "cloud-ubuntu-24.04 LTS"
      allocate_public_ipv4 = true
    }
    # Adicione mais VMs conforme necessário:
    # "vm-2" = {
    #   name                = "test-vm-2"
    #   machine_type        = "BV2-2-20"
    #   image               = "cloud-ubuntu-24.04 LTS"
    #   allocate_public_ipv4 = true
    # }
  }
}

module "object_storage" {
  source = "../../modules/object-storage"
  project_name = "myproject"
  environment  = "staging"
  buckets = {
    "react-static" = {
      name       = "react-static"
      versioning = true
      is_public  = true  # Bucket público - permite leitura para todos
      enable_cors = true
      cors_config = {
        allowed_methods = ["GET", "HEAD"]
        allowed_origins = ["*"]
        allowed_headers = ["*"]
        max_age_seconds = 3600
        expose_headers = []
      }
    }
    "django-static" = {
      name       = "django-static"
      versioning = true
      is_public  = true  # Bucket público - permite leitura para todos
      enable_cors = true
      cors_config = {
        allowed_methods = ["GET", "HEAD"]
        allowed_origins = ["*"]
        allowed_headers = ["*"]
        max_age_seconds = 3600
        expose_headers = []
      }
    }
    "django-media" = {
      name       = "django-media"
      versioning = true
      is_public  = false  # Bucket privado - acesso restrito
      enable_cors = false
    }
    # Adicione mais buckets conforme necessário:
    # "backup-bucket" = {
    #   name       = "backup"
    #   versioning = true
    #   lock       = true
    #   is_public  = false  # Bucket privado
    #   enable_cors = false
    # }
    # "public-assets" = {
    #   name       = "public-assets"
    #   versioning = false
    #   is_public  = true   # Bucket público
    #   enable_cors = true
    #   cors_config = {
    #     allowed_methods = ["GET", "HEAD"]
    #     allowed_origins = ["https://example.com"]
    #   }
    # }
  }
}