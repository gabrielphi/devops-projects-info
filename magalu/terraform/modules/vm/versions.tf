terraform {
  required_providers {
    mgc = {
      source                = "magalucloud/mgc"
      version               = "0.41.0"
      configuration_aliases = [mgc.nordeste]
    }
  }
}

