resource "kubectl_manifest" "namespace" {
  yaml_body = file("${path.module}/../../k8s/namespace.yaml")
}

resource "kubectl_manifest" "nginx_configmap" {
  depends_on = [kubectl_manifest.namespace]
  yaml_body  = file("${path.module}/../../k8s/nginx-configmap.yaml")
}

resource "kubectl_manifest" "service" {
  depends_on = [kubectl_manifest.namespace]
  yaml_body  = file("${path.module}/../../k8s/service.yaml")
}

# Ingress eliminado: kubeadm puro no incluye ingress controller.
# La app se expone via NodePort 30080 (accesible en http://<EC2_IP>:30080).

resource "kubectl_manifest" "deployment" {
  depends_on = [kubectl_manifest.namespace, kubectl_manifest.nginx_configmap]
  yaml_body = replace(
    file("${path.module}/../../k8s/deployment.yaml"),
    "IMAGE_PLACEHOLDER",
    local.image
  )
}

# Stack de observabilidad: Prometheus + Grafana + Alertmanager + node-exporter
resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true
  version          = "87.2.1"

  values = [file("${path.module}/../../k8s/monitor/kube-prometheus-stack.yaml")]
}

# Pushgateway para recibir metricas del pipeline CI/CD (IE3)
# Depende de kube-prometheus-stack porque el ServiceMonitor CRD debe existir
resource "helm_release" "pushgateway" {
  name       = "pushgateway"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-pushgateway"
  namespace  = "monitoring"
  version    = "2.13.0"
  depends_on = [helm_release.kube_prometheus_stack]

  values = [file("${path.module}/../../k8s/monitor/pushgateway.yaml")]
}

# ServiceMonitor para que Prometheus scrapee el exporter de nginx
resource "kubectl_manifest" "servicemonitor" {
  depends_on = [kubectl_manifest.namespace, helm_release.kube_prometheus_stack]
  yaml_body  = file("${path.module}/../../k8s/servicemonitor.yaml")
}

# Reglas de alerta de Prometheus (IE6)
resource "kubectl_manifest" "prometheus_rules" {
  depends_on = [kubectl_manifest.namespace, helm_release.kube_prometheus_stack]
  yaml_body  = file("${path.module}/../../k8s/monitor/prometheus-rules.yaml")
}

# ConfigMap con el dashboard de Grafana (IE3)
resource "kubectl_manifest" "grafana_dashboard" {
  depends_on = [helm_release.kube_prometheus_stack]
  yaml_body  = file("${path.module}/../../k8s/monitor/dashboards/rotsu-dashboard-configmap.yaml")
}
