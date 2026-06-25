output "app_url" {
  description = "URL del microservicio (via NodePort 30000/LB). Requiere IP publica de la EC2 (output de terraform/)"
  value       = "http://<EC2_PUBLIC_IP>"
}

output "grafana_url" {
  description = "URL del dashboard Grafana (NodePort 30100)"
  value       = "http://<EC2_PUBLIC_IP>:30100"
}

output "pushgateway_url" {
  description = "URL del Pushgateway para metricas CI (NodePort 9091)"
  value       = "http://<EC2_PUBLIC_IP>:9091"
}
