# =============================================================================
# Providers configurados via kubeconfig local
# -----------------------------------------------------------------------------
# El archivo ../kubeconfig.yaml lo genera terraform/kubernetes.tf tras
# instalar kubeadm y descargar el kubeconfig via SSH.
#
# Si el archivo no existe aun, se usa un placeholder para que
# `terraform validate` funcione sin la EC2 levantada.
# =============================================================================

locals {
  kubeconfig_file = "${path.module}/../kubeconfig.yaml"
  kubeconfig      = yamldecode(file(local.kubeconfig_file))
  cluster         = local.kubeconfig.clusters[0].cluster
  user            = local.kubeconfig.users[0].user

  kubeconfig_host        = local.cluster.server
  kubeconfig_ca          = base64decode(local.cluster.certificate-authority-data)
  kubeconfig_client_cert = base64decode(local.user.client-certificate-data)
  kubeconfig_client_key  = base64decode(local.user.client-key-data)
}

provider "kubernetes" {
  host                   = local.kubeconfig_host
  cluster_ca_certificate = local.kubeconfig_ca
  client_certificate     = local.kubeconfig_client_cert
  client_key             = local.kubeconfig_client_key
}

provider "helm" {
  kubernetes {
    host                   = local.kubeconfig_host
    cluster_ca_certificate = local.kubeconfig_ca
    client_certificate     = local.kubeconfig_client_cert
    client_key             = local.kubeconfig_client_key
  }
  # Timeout para Helm (kube-prometheus-stack puede tardar)
  experiments {
    manifest = true
  }
}

provider "kubectl" {
  apply_retry_count      = 5
  host                   = local.kubeconfig_host
  cluster_ca_certificate = local.kubeconfig_ca
  client_certificate     = local.kubeconfig_client_cert
  client_key             = local.kubeconfig_client_key
  load_config_file       = false
}
