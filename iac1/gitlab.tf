resource "kubernetes_namespace" "gitlab-runner" {
  metadata {
    name = "gitlab-runner"
  }
}

resource "helm_release" "gitlab-runner" {
  name = "gitlab"

  repository = "https://charts.gitlab.io"
  chart = "gitlab-runner"

  values = [
    file("gitlab/values.yml")
  ]

  namespace = kubernetes_namespace.gitlab-runner.metadata[0].name
}
