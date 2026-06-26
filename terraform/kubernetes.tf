# =============================================================================
# kubernetes.tf - Provisionamiento del cluster Kubernetes via kubeadm
# -----------------------------------------------------------------------------
# kubeadm se instala via cloud-init (ver ec2.tf). Este archivo:
#   1. Espera a kubeadm init termine (señal: archivo /var/lib/cloud/instance/k8s-ready)
#   2. Descarga el kubeconfig via SSH al directorio local
#   3. El sub-modulo terraform/k8s/ lo lee en el segundo apply
#
# NOTA IMPORTANTE: Este setup usa SSH en lugar de AWS SSM.
# Razon: AWS Academy Learner Lab NO permite crear IAM Roles, y sin IAM
# instance profile el SSM agent no puede registrar la instancia.
# SSH funciona con key pair que SÍ se puede crear en Learner Lab.
# =============================================================================

locals {
  k8s_instance_id = var.use_spot ? aws_spot_instance_request.k3s[0].id : aws_instance.k3s[0].id
  k8s_public_ip   = var.use_spot ? aws_spot_instance_request.k3s[0].public_ip : aws_instance.k3s[0].public_ip
  k8s_ssh_user    = "ubuntu"
  k8s_ssh_key_path = var.enable_ssh_access ? (
    var.ssh_public_key != "" ? "${path.module}/k3s_key" : "${path.module}/k3s_key"
  ) : "${path.module}/k3s_key"
}

# Guardar la llave privada SSH localmente (si fue generada por Terraform)
resource "local_file" "k3s_ssh_key" {
  count           = var.enable_ssh_access && var.ssh_public_key == "" ? 1 : 0
  content         = tls_private_key.k3s[0].private_key_openssh
  filename        = "${path.module}/k3s_key"
  file_permission = "0600"
}

# Esperar a que kubeadm init termine via SSH
resource "null_resource" "k8s_ready" {
  depends_on = [
    local_file.k3s_ssh_key,
  ]

  triggers = {
    instance_id = local.k8s_instance_id
    public_ip   = local.k8s_public_ip
  }

  connection {
    type        = "ssh"
    host        = local.k8s_public_ip
    user        = local.k8s_ssh_user
    private_key = var.ssh_public_key != "" ? file(local.k8s_ssh_key_path) : tls_private_key.k3s[0].private_key_pem
    timeout     = "15m"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "echo 'Esperando archivo k8s-ready (cloud-init)...'",
      "for i in $(seq 1 120); do if [ -f /var/lib/cloud/instance/k8s-ready ]; then echo \"k8s-ready encontrado tras $${i} iteraciones\"; break; fi; sleep 10; done",
      "if [ ! -f /var/lib/cloud/instance/k8s-ready ]; then echo 'ERROR: k8s-ready no se creo en 20 min'; sudo journalctl -u cloud-final --no-pager | tail -50 || true; exit 1; fi",
      "echo 'Esperando nodo Ready...'",
      # Usar sudo -E para preservar KUBECONFIG; kubectl local lo encuentra
      "sudo -E KUBECONFIG=/etc/kubernetes/admin.conf kubectl wait --for=condition=Ready node --all --timeout=300s",
      "echo 'Cluster Kubernetes listo'",
    ]
  }
}

# Descargar kubeconfig localmente
resource "null_resource" "download_kubeconfig" {
  depends_on = [null_resource.k8s_ready]

  triggers = {
    instance_id = local.k8s_instance_id
    public_ip   = local.k8s_public_ip
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -eu
      echo "Descargando kubeconfig desde ${local.k8s_public_ip}..."
      scp -o StrictHostKeyChecking=no -o ConnectTimeout=30 \
        -i ${local.k8s_ssh_key_path} \
        ${local.k8s_ssh_user}@${local.k8s_public_ip}:/home/ubuntu/.kube/config \
        ${path.module}/kubeconfig.yaml
      chmod 600 ${path.module}/kubeconfig.yaml
      echo "kubeconfig guardado en ${path.module}/kubeconfig.yaml"
    EOT
  }
}
