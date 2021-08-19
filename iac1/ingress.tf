resource "kubernetes_namespace" "ingress-nginx" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "helm_release" "ingress-nginx" {
  name = "ingress-nginx"

  repository = "https://helm.nginx.com/stable"
  chart = "nginx-ingress"

  namespace = kubernetes_namespace.ingress-nginx.metadata[0].name
}

data "kubernetes_service" "ingress-nginx-service" {
  metadata {
    name = "${helm_release.ingress-nginx.name}-nginx-ingress"
    namespace = helm_release.ingress-nginx.namespace
  }
}