# ==============================================================================
# AWS Load Balancer Controller - Helm Release
# ==============================================================================

resource "helm_release" "lb_controller" {
  count = var.enable_aws_load_balancer_controller ? 1 : 0

  name       = var.lb_controller_helm_release_name
  repository = var.lb_controller_helm_repo
  chart      = var.lb_controller_helm_chart
  version    = var.lb_controller_chart_version
  namespace  = var.lb_controller_namespace

  wait            = var.lb_controller_helm_wait
  wait_for_jobs   = var.lb_controller_helm_wait_for_jobs
  timeout         = var.lb_controller_helm_timeout
  cleanup_on_fail = var.lb_controller_helm_cleanup_on_fail

  values = [
    yamlencode({
      clusterName = var.cluster_name
      region      = var.aws_region
      vpcId       = var.vpc_id

      serviceAccount = {
        create = var.lb_controller_service_account_create
        name   = var.lb_controller_service_account
        annotations = {
          # The parenthesis () evaluate the local variables as dynamic map keys
          (local.lb_controller_role_arn_key)     = aws_iam_role.lb_controller[0].arn # FIX: Removed "aws_" from the role name
          (local.lb_controller_sts_endpoint_key) = tostring(var.lb_controller_use_sts_regional_endpoints)
        }
      }

      image = {
        tag = var.lb_controller_image_tag
      }

      replicaCount = var.lb_controller_replica_count

      resources = {
        requests = {
          cpu    = var.lb_controller_cpu_request
          memory = var.lb_controller_memory_request
        }
        limits = {
          cpu    = var.lb_controller_cpu_limit
          memory = var.lb_controller_memory_limit
        }
      }

      podDisruptionBudget = {
        maxUnavailable = var.lb_controller_pdb_max_unavailable
      }

      affinity = {
        podAntiAffinity = {
          preferredDuringSchedulingIgnoredDuringExecution = [
            {
              weight = var.lb_controller_pod_anti_affinity_weight
              podAffinityTerm = {
                topologyKey = var.lb_controller_topology_key
                labelSelector = {
                  matchExpressions = [
                    {
                      key      = var.lb_controller_app_name_label_key
                      operator = var.lb_controller_app_name_label_operator
                      values   = [var.lb_controller_app_name_label_value]
                    }
                  ]
                }
              }
            }
          ]
        }
      }

      enableWaf    = var.enable_waf
      enableWafv2  = var.enable_wafv2
      enableShield = var.enable_shield
      logLevel     = var.lb_controller_log_level
    })
  ]
}
