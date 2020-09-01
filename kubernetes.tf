# # Kubernetes provider
# # https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster#optional-configure-terraform-kubernetes-provider
# # To learn how to schedule deployments and services using the provider, go here: ttps://learn.hashicorp.com/terraform/kubernetes/deploy-nginx-kubernetes.

provider "kubernetes" {
  load_config_file       = "false"
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "scalable-nginx-example"
    labels = {
      App = "ScalableNginxExample"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "ScalableNginxExample"
      }
    }
    template {
      metadata {
        labels = {
          App = "ScalableNginxExample"
        }
      }
      spec {
        container {
          image = "nginx:1.7.8"
          name  = "example"

          port {
            container_port = 80
          }

          resources {
            limits {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "example" {
  metadata {
    name = "scalable-nginx-svc"
  }
  spec {
    selector = {
      App = "ScalableNginxExample"
    }
    port {
      port        = 8080
      target_port = 80
    }
  }
}
resource "kubernetes_horizontal_pod_autoscaler" "example" {
  metadata {
    name = "hpa-example"
  }

  spec {
    max_replicas = 10
    min_replicas = 1
    target_cpu_utilization_percentage = 40

    scale_target_ref {
      api_version = "apps/v1"
      kind = "Deployment"
      name = "scalable-nginx-example"
    }
  }
}

module "metrics_server" {
  source = "cookielab/metrics-server/kubernetes"
  version = "0.10.0"
}
