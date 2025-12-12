locals {
  base_name = var.project_name != "" && var.environment != "" ? "${var.project_name}-${var.environment}" : ""
  
  # Gera o nome completo do bucket: se base_name existe, usa prefixo, senão usa apenas o name
  bucket_names = {
    for k, v in var.buckets : k => local.base_name != "" ? "${local.base_name}-${v.name}" : v.name
  }
  
  # Determina a policy para cada bucket
  # Se policy_template for especificado, usa o template customizado
  # Caso contrário, se is_public = true, aplica policy de leitura pública
  # Se is_public = false ou não especificado, policy será null (bucket privado por padrão)
  bucket_policies = {
    for k, v in var.buckets : k => (
      v.policy_template != null ? (
        # Template customizado tem prioridade
        templatefile("${path.module}/templates/${v.policy_template}", 
          merge({ bucket = local.bucket_names[k] }, v.policy_vars))
      ) : (
        v.is_public == true ? (
          # Bucket público: permite leitura para todos
          templatefile("${path.module}/templates/public_read_policy.json.tpl", 
            { bucket = local.bucket_names[k] })
        ) : null
        # Se is_public = false ou não especificado, policy = null (bucket privado por padrão)
      )
    )
  }
  
  # Configura CORS para cada bucket (null se não habilitado)
  bucket_cors = {
    for k, v in var.buckets : k => (
      v.enable_cors == true ? {
        allowed_methods = v.cors_config != null ? v.cors_config.allowed_methods : ["GET", "HEAD"]
        allowed_origins = v.cors_config != null ? v.cors_config.allowed_origins : ["*"]
        allowed_headers = v.cors_config != null ? v.cors_config.allowed_headers : ["*"]
        max_age_seconds = v.cors_config != null ? v.cors_config.max_age_seconds : 3600
        expose_headers  = v.cors_config != null ? v.cors_config.expose_headers : []
      } : null
    )
  }
}

resource "mgc_object_storage_buckets" "buckets" {
  for_each = var.buckets

  bucket     = local.bucket_names[each.key]
  versioning = each.value.versioning
  lock       = each.value.lock != null ? each.value.lock : false
  policy     = local.bucket_policies[each.key]
  cors       = local.bucket_cors[each.key]
}
