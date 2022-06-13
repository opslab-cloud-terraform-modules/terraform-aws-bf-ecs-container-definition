variable "name" {
  description = "The name of the service. Up to 255 characters (a-z, A-Z, 0-9, -, _ allowed)"
  type        = string
}

variable "container_name" {
  description = "The name of container. Use when container name differs from service name"
  type        = string
  default     = ""
}

variable "task_definition_name" {
  description = "The name of task definition. Use when task definition name differs from service name"
  type        = string
  default     = ""
}

variable "cpu" {
  description = "The number of cpu units to reserve for the container. This is optional for tasks using Fargate launch type and the total amount of container_cpu of all containers in a task will need to be lower than the task-level cpu value"
  type        = number
  default     = 0
}

variable "memory" {
  description = "The amount of memory (in MiB) to allow the container to use. This is a hard limit, if the container attempts to exceed the container_memory, the container is killed. This field is optional for Fargate launch type and the total amount of container_memory of all containers in a task will need to be lower than the task memory value"
  type        = number
  default     = null
}

variable "memory_reservation" {
  description = "The amount of memory (in MiB) to reserve for the container. If container needs to exceed this threshold, it can do so up to the set container_memory hard limit"
  type        = number
  default     = null
}

variable "port_mappings" {
  description = "The port mappings to configure for the container. This is a list of maps. Each map should contain \"containerPort\", \"hostPort\", and \"protocol\", where \"protocol\" is one of \"tcp\" or \"udp\". If using containers in a task with the awsvpc or host network mode, the hostPort can either be left blank or set to the same value as the containerPort"
  type = list(object({
    containerPort = number
    hostPort      = number
    protocol      = string
  }))
  default = [
    {
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
    }
  ]
}

variable "healthcheck" {
  description = "A map containing command (string), timeout, interval (duration in seconds), retries (1-10, number of times to retry before marking container unhealthy), and startPeriod (0-300, optional grace period to wait, in seconds, before failed healthchecks count toward retries)"
  type = object({
    command     = list(string)
    retries     = number
    timeout     = number
    interval    = number
    startPeriod = number
  })
  default = null
}

variable "environment" {
  description = "The environment variables to pass to the container"
  type = list(object({
    name  = string
    value = string
  }))
  default = null
}

variable "map_environment" {
  description = "The environment variables to pass to the container. This is a map of string: {key: value}, environment override map_environment"
  type        = map(string)
  default     = null
}

variable "map_secrets" {
  type        = map(string)
  description = "The secrets variables to pass to the container. This is a map of string: {key: value}. map_secrets overrides secrets"
  default     = null
}

variable "environment_files" {
  description = "One or more files containing the environment variables to pass to the container. This maps to the --env-file option to docker run. The file must be hosted in Amazon S3."
  type = list(object({
    value = string
    type  = string
  }))
  default = null
}

variable "secrets" {
  description = "The SSM parameters to pass to the container"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "repo" {
  description = "Docker repo"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag. Used to initiate new task definition from scratch using image:latest or when CI/CD processes does not update tags in container definitions."
  type        = string
  default     = ""
}

variable "volumes_from" {
  description = "A list of VolumesFrom maps which contain \"sourceContainer\" (name of the container that has the volumes to mount) and \"readOnly\" (whether the container can write to the volume)"
  type = list(object({
    sourceContainer = string
    readOnly        = bool
  }))
  default = []
}

variable "mount_points" {
  description = "Container mount points. This is a list of maps, where each map should contain a `containerPath` and `sourceVolume`"
  type = list(object({
    containerPath = string
    sourceVolume  = string
    readOnly      = bool
  }))
  default = []
}

variable "container_depends_on" {
  type = list(object({
    containerName = string
    condition     = string
  }))
  description = "The dependencies defined for container startup and shutdown. A container can contain multiple dependencies. When a dependency is defined for container startup, for container shutdown it is reversed. The condition can be one of START, COMPLETE, SUCCESS or HEALTHY"
  default     = null
}

# https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_LinuxParameters.html
variable "linux_parameters" {
  type = object({
    capabilities = object({
      add  = list(string)
      drop = list(string)
    })
    devices = list(object({
      containerPath = string
      hostPath      = string
      permissions   = list(string)
    }))
    initProcessEnabled = bool
    maxSwap            = number
    sharedMemorySize   = number
    swappiness         = number
    tmpfs = list(object({
      containerPath = string
      mountOptions  = list(string)
      size          = number
    }))
  })
  description = "Linux-specific modifications that are applied to the container, such as Linux kernel capabilities. For more details, see https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_LinuxParameters.html"
  default     = null
}

variable "firelens_endpoint" {
  type    = string
  default = "firelens_cwl"
  #validation {
  #!TODO: Finish writing validation rule
  #}
}

###
# Log consumption

variable "cloudwatch_log_group" {
  description = "Name of the log group"
  type        = string
}

variable "logcollection_parsejson" {
  description = "Parse container log output as JSON [doc](https://github.com/aws-samples/amazon-ecs-firelens-examples/tree/master/examples/fluent-bit/parse-json)"
  default     = false
  type        = bool
}

###
# DataDog monitoring

variable "datadog_domain" {
  description = "The default public endpoint endpoint is in US"
  default     = "datadoghq.com"
}

variable "ssm_datadog_api_key" {
  type        = string
  description = "Path to SSM parameter storing the encrypted DataDog API key"
  default     = null
}

variable "datadog_log_level" {
  description = "https://docs.datadoghq.com/agent/troubleshooting/debug_mode/?tab=agentv6v7#agent-log-level"
  default     = "WARN"
}

variable "datadog_agent_container_source" {
  description = "https://docs.datadoghq.com/agent/docker/?tab=standard#misc"
  default     = "ecs_fargate"
}

variable "datadog_container_exclude" {
  description = "Blocklist of containers to exclude (separated by spaces). Use .* to exclude all. For example: \"image:image_name_3 image:image_name_4\""
  default     = "name:datadog-agent name:firelens"
}

variable "docker_labels" {
  description = "The configuration options to send to the `docker_labels` of main container"
  type        = map(string)
  default     = null
}

variable "datadog_image_url" {
  description = "URL to datadog-agent docker image"
  default     = "datadog/agent:latest"
}

variable "datadog_docker_labels" {
  description = "Docker labels used by DataDog agent for auto-discovery [doc](https://docs.datadoghq.com/agent/autodiscovery/basic_autodiscovery?tab=docker)"
  type        = map(string)
  default     = null
}

variable "datadog_environment" {
  description = "Customer environment variables used by DataDog agent [doc](https://docs.datadoghq.com/agent/docker/?tab=standard#environment-variables)"
  default     = []
  type = list(object({
    name  = string
    value = string
  }))
}

variable "datadog_apm_enable" {
  description = "When set to true, the Datadog Agent accepts trace metrics"
  default     = true
  type        = bool
}

variable "datadog_apm_ignore_resources" {
  description = "Configure resources for the Agent to ignore. Format should be comma separated, regular expressions. Example: GET /ignore-me,(GET|POST) /and-also-me."
  default     = ""
}

variable "datadog_process_enable" {
  description = "Enable the DataDog process agent"
  default     = true
  type        = bool
}

variable "datadog_logcollection_enable" {
  description = "Monitor Fargate logs by using the AWS FireLens integration built on Datadogs Fluentbit output plugin to send logs to Datadog"
  default     = false
  type        = bool
}

variable "datadog_logcollection_source" {
  description = "The source option will automatically trigger a log processing pipeline in Datadog for your integration [if available](https://docs.datadoghq.com/integrations/#cat-log-collection)."
  default     = "php"
  type        = string
}

variable "datadog_tags" {
  description = "Map of tags sent to DataDog"
  default     = {}
}

## Firelens S3 configuration input

variable "s3_bucket_name" {
  description = "Name of S3 bucket for firelens to write logs to"
  default     = ""
}

## Firelens Kinesis configuration input

variable "kinesis_stream_name" {
  description = "Name of Kinesis stream for firelens to write logs to"
  default     = ""
}

## Firelens Firehose configuration input

variable "firehose_stream_name" {
  description = "Name of Firehose delivery stream for firelens to write logs to"
  default     = ""
}

