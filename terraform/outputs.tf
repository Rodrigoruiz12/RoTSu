output "k8s_public_ip" {
  description = "IP publica de la instancia EC2 con Kubernetes"
  value       = var.use_spot ? aws_spot_instance_request.k3s[0].public_ip : aws_instance.k3s[0].public_ip
}

output "k8s_instance_id" {
  description = "ID de la instancia EC2 con Kubernetes"
  value       = var.use_spot ? aws_spot_instance_request.k3s[0].id : aws_instance.k3s[0].id
}

output "grafana_url" {
  description = "URL para acceder al dashboard de Grafana"
  value       = "http://${var.use_spot ? aws_spot_instance_request.k3s[0].public_ip : aws_instance.k3s[0].public_ip}:30100"
}

output "grafana_admin_password" {
  description = "Password de admin de Grafana (cambiar en produccion)"
  value       = "rotsu-admin"
  sensitive   = true
}

output "pushgateway_url" {
  description = "URL del Pushgateway para enviar metricas de CI"
  value       = "http://${var.use_spot ? aws_spot_instance_request.k3s[0].public_ip : aws_instance.k3s[0].public_ip}:9091"
}

output "app_url" {
  description = "URL del microservicio RoTSu desplegado (NodePort 30080)"
  value       = "http://${var.use_spot ? aws_spot_instance_request.k3s[0].public_ip : aws_instance.k3s[0].public_ip}:30080"
}

output "ssh_connection_command" {
  description = "Comando para conectar a la EC2 via SSH"
  value       = "ssh -i ${var.enable_ssh_access ? (var.ssh_public_key == "" ? "${path.module}/k3s_key" : "~/.ssh/id_ed25519") : "<deshabilitado>"} ubuntu@${var.use_spot ? aws_spot_instance_request.k3s[0].public_ip : aws_instance.k3s[0].public_ip}"
}

output "ssh_private_key_path" {
  description = "Ruta a la llave privada SSH (generada por Terraform si no se proveyo una)"
  value       = var.ssh_public_key == "" ? "${path.module}/k3s_key" : "Tu propia llave (~/.ssh/id_ed25519)"
}

output "k8s_join_command" {
  description = "Comando para unir nodos adicionales al cluster (kubeadm join)"
  value       = "kubeadm token create --print-join-command"
}

output "kubeconfig_local_path" {
  description = "Ruta local al kubeconfig descargado via SSH (consumido por terraform/k8s/)"
  value       = "${path.module}/kubeconfig.yaml"
}
