provider "mgc" {
  api_key         = var.api_key
  region          = var.region
  key_pair_id     = var.mgc_key_pair_id
  key_pair_secret = var.mgc_key_pair_secret
}

provider "mgc" {
  alias          = "nordeste"
  api_key        = var.api_key
  region         = "br-ne1"
  key_pair_id    = var.mgc_key_pair_id
  key_pair_secret = var.mgc_key_pair_secret
}

