locals {

  ###
  # DataDog agent tags config
  # DD_TAGS values are separated by space
  # Excluding github urls to avoid special characters
  # TODO: handle special chars in all tags
  dd_tags = join(" ", [for k, v in var.datadog_tags : "${k}:${v}" if k != "giturl"])

  ###
  # DataDog container config
  # https://docs.datadoghq.com/integrations/ecs_fargate/#web-ui
  # https://docs.datadoghq.com/agent/troubleshooting/debug_mode/?tab=agentv6v7
  # https://docs.datadoghq.com/tracing/setup/php/#environment-variable-configuration

  dd_environment = concat(var.datadog_environment,
    [
      {
        name  = "DD_APM_ENABLED",
        value = var.datadog_apm_enable
      },
      {
        name  = "DD_LOG_LEVEL",
        value = "WARN"
      },
      {
        name  = "DD_PROCESS_AGENT_ENABLED",
        value = var.datadog_process_enable
      },
      {
        name  = "DD_SERVICE_NAME",
        value = var.name
      },
      {
        name  = "DD_TRACE_ANALYTICS_ENABLED",
        value = var.datadog_apm_enable
      },
      {
        name  = "ECS_FARGATE",
        value = "true"
      },
      # https://docs.datadoghq.com/integrations/ecs_fargate/#other-environment-variables
      {
        name  = "DD_TAGS",
        value = local.dd_tags
      },
      {
        name  = "DD_AC_EXCLUDE",
        value = "image:.*"
      },
      {
        name  = "DD_AC_INCLUDE",
        value = "image:${var.repo}.*"
      }

  ])

  dd_secrets = [
    {
      name      = "DD_API_KEY",
      valueFrom = var.ssm_datadog_api_key
    }
  ]
}

# https://docs.datadoghq.com/integrations/ecs_fargate/
module "datadog" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.41.0"

  container_cpu                = 10
  container_image              = "datadog/agent:latest"
  container_memory             = null
  container_memory_reservation = 256
  container_name               = "datadog-agent"
  environment                  = local.dd_environment
  mount_points                 = []
  port_mappings                = []
  secrets                      = local.dd_secrets
  volumes_from                 = []

  # The datadog-agent's own logs are sent to cloudwatch
  log_configuration = {
    logDriver = "awslogs",
    options = {
      awslogs-datetime-format = "%Y-%m-%d %H:%M:%S",
      awslogs-region          = data.aws_region.this.name,
      awslogs-stream-prefix   = var.name,
      awslogs-group           = var.cloudwatch_log_group
    }
    secretOptions = []
  }
}
