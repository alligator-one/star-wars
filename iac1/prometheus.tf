resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "kube-monitoring"
  }
}

resource "random_password" "grafana_password" {
  length = 10
}

resource "helm_release" "prometheus-stack" {
  name = "monitoring"

  repository = "https://prometheus-community.github.io/helm-charts"
  chart = "kube-prometheus-stack"

  values = [
    file("prometheus/values.yml")
  ]

  set {
    name = "grafana.adminPassword"
    value = random_password.grafana_password.result
  }

  namespace = kubernetes_namespace.monitoring.metadata[0].name
}

resource "time_sleep" "blackbox-sleep" {
  create_duration = "10s"
  depends_on = [
    helm_release.prometheus-stack
  ]
}

resource "helm_release" "blackbox-exporter" {

  name = "blackbox"

  repository = "https://prometheus-community.github.io/helm-charts"
  chart = "prometheus-blackbox-exporter"

  values = [
    file("blackbox/values.yml")
  ]

  namespace = kubernetes_namespace.monitoring.metadata[0].name

  depends_on = [
    time_sleep.blackbox-sleep
  ]
}

resource "helm_release" "loki-stack" {
  name = "logging"

  repository = "https://grafana.github.io/helm-charts"
  chart = "loki-stack"

  namespace = kubernetes_namespace.monitoring.metadata[0].name
}


resource "cloudflare_record" "ingress-record" {
  name = "metrics"
  type = "A"
  zone_id = var.cloudflare_zone_id
  value = data.kubernetes_service.ingress-nginx-service.status.0.load_balancer.0.ingress.0.ip
  proxied = true
}
