/*
* Validate SSM parameters to avoid failing ECS deployments
* Fargate supports secrets from other resources than SSM,
* but the ARNs from ie Secrets Manager don't contain the :parameter string
*/

data "aws_ssm_parameter" "datadog_secrets" {
  for_each = { for s in var.datadog_secrets :
    # * Split out the name of the parameter
    s.name => split(":parameter", s.valueFrom)[1]
    # * Only apply to ssm ARNs
    if length(regexall(":ssm:", s.valueFrom)) > 0
  }
  name = each.value
}

/*
* Validate SecretsManager secrets to avoid failing ECS deployments
* Fargate supports secrets from other resources than SecretsManager,
* but the ARNs from ie SSM don't contain the :secretsmanager: string
*/

data "aws_secretsmanager_secret" "datadog_secrets" {
  for_each = { for s in var.datadog_secrets :
    # * Remove versioning/json-key incase it has been specified
    s.name => join(":", slice(split(":", s.valueFrom), 0, 7))
    # * Only apply to secretsmanager ARNs
    if length(regexall(":secretsmanager:", s.valueFrom)) > 0
  }

  arn = each.value
}


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

  dd_environment_tmp = concat(var.datadog_environment,
    [
      {
        name  = "DD_APM_ENABLED",
        value = var.datadog_apm_enable
      },
      {
        name  = "DD_APM_IGNORE_RESOURCES",
        value = var.datadog_apm_ignore_resources
      },
      {
        name  = "DD_CONTAINER_EXCLUDE",
        value = var.datadog_container_exclude
      },
      {
        name  = "DD_LOG_LEVEL",
        value = upper(var.datadog_log_level)
      },
      {
        name  = "DD_PROCESS_AGENT_ENABLED",
        value = var.datadog_process_enable
      },
      {
        name  = "DD_PROCESS_AGENT_CONTAINER_SOURCE",
        value = var.datadog_agent_container_source
      },
      {
        name  = "DD_SERVICE",
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
      {
        name  = "DD_SITE"
        value = var.datadog_domain
      },
      # https://docs.datadoghq.com/integrations/ecs_fargate/#other-environment-variables
      {
        name  = "DD_TAGS"
        value = local.dd_tags
      }
  ])

  # TODO
  #  - find out how to avoid empty values in map
  #  - diff from empty dd_tags still results in the following plan which results in dd_tags = ""
  /*
  options = {
      Host           = "http-intake.logs.datadoghq.eu"
      Name           = "datadog"
      TLS            = "on"
      compress       = "gzip"
      dd_message_key = "log"
      dd_service     = "foo"
      dd_source      = "php"
    ~ dd_tags        = "Environment:test,MonitoringScope:foo,,Terraform:true" -> ""
      provider       = "ecs"
    }
  */

  #
  # IMPORTANT: no keys can have empty values, or you get cryptic errors like the following:
  # [2020/10/12 16:22:54] [  Error] File /fluent-bit/etc/fluent-bit.conf
  # [2020/10/12 16:22:54] [  Error] Error in line 32: Key has an empty value
  dd_environment = [
    for m in local.dd_environment_tmp : { name = m.name, value = m.value } if m.value != ""
  ]

  dd_secrets = concat(
    [
      {
        name      = "DD_API_KEY",
        valueFrom = var.ssm_datadog_api_key
      }
    ],
    var.datadog_secrets
  )
}

# https://docs.datadoghq.com/integrations/ecs_fargate/
module "datadog" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.56.0"

  container_cpu                = 10
  container_image              = var.datadog_image_url
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
