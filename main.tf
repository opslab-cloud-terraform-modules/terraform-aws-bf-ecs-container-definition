
data "aws_region" "this" {}

# Verify cluster
data "aws_ecs_cluster" "this" {
  cluster_name = var.cluster_name
}

/*
* Validate SSM parameters to avoid failing ECS deployments
* Fargate supports secrets from other resources than SSM,
* but the ARNs from ie Secrets Manager don't contain the :parameter string
*/
data "aws_ssm_parameter" "this" {
  for_each = { for s in var.secrets :
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
data "aws_secretsmanager_secret" "this" {
  for_each = { for s in var.secrets :
    # * Remove versioning/json-key incase it has been specified
    s.name => join(":", slice(split(":", s.valueFrom), 0, 7))
    # * Only apply to secretsmanager ARNs
    if length(regexall(":secretsmanager:", s.valueFrom)) > 0
  }

  arn = each.value
}

# For existing tasks, CI/CD pipelines will create new revisions
# for each image built, tagged and deployed to ECS.
# The terraform state will remain on the old task def revision.
data "aws_ecs_task_definition" "this" {
  count           = var.image_tag != "" ? 0 : 1
  task_definition = var.task_definition_name != "" ? var.task_definition_name : var.name
}

# Find existing definition if not first creation or overridden by image_tag
data "aws_ecs_container_definition" "this" {
  count           = var.image_tag != "" ? 0 : 1
  task_definition = data.aws_ecs_task_definition.this[0].id
  container_name  = var.container_name != "" ? var.container_name : var.name
}

module "this" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.57.0"

  container_cpu                = var.cpu
  container_depends_on         = var.container_depends_on
  container_memory             = var.memory
  container_memory_reservation = var.memory_reservation
  container_name               = var.container_name != "" ? var.container_name : var.name
  environment                  = var.environment
  environment_files            = var.environment_files
  essential                    = true
  healthcheck                  = var.healthcheck
  linux_parameters             = var.linux_parameters
  map_environment              = var.map_environment
  map_secrets                  = var.map_secrets
  mount_points                 = var.mount_points
  port_mappings                = var.port_mappings
  secrets                      = var.secrets
  volumes_from                 = var.volumes_from

  # Use current running image tag from existing ECS tasks or :latest for new.
  container_image = coalescelist(
    data.aws_ecs_container_definition.this[*].image,
    [format("%s:%s", var.repo, var.image_tag)]
  )[0]

  docker_labels = merge(
    coalesce(var.docker_labels, {}),
    coalesce(var.datadog_docker_labels, {}),
    { "com.datadoghq.tags.service" = var.name }
  )

  # Logs are sent to datadog or cloudwatch by fluent-bit
  log_configuration = var.datadog_logcollection_enable ? local.firelens_config_datadog : local.firelens_config_cwl
}
