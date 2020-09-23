
data "aws_region" "this" {}

# Verify cluster
data "aws_ecs_cluster" "this" {
  cluster_name = var.cluster_name
}

# Validate SSM parameters to avoid failing ECS deployments
# Fargate supports secrets from other resources than SSM,
# but the ARNs from ie Secrets Manager don't contain the :parameter string
data "aws_ssm_parameter" "this" {
  for_each = { for s in var.secrets : s.name => split(":parameter", s.valueFrom)[1] }
  name     = each.value
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
  version = "0.41.0"

  container_cpu                = var.cpu
  container_memory             = var.memory
  container_memory_reservation = var.memory_reservation
  container_name               = var.container_name != "" ? var.container_name : var.name
  environment                  = var.environment
  essential                    = true
  healthcheck                  = var.healthcheck
  map_environment              = var.map_environment
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
    coalesce(var.datadog_docker_labels, {})
  )

  # Logs are sent to datadog or cloudwatch by fluent-bit
  log_configuration = var.datadog_logcollection_enable ? local.firelens_config_datadog : local.firelens_config_cwl
}
