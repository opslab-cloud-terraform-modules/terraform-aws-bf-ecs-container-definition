# Fargate task definition

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Description](#description)
  - [Side-cars](#side-cars)
  - [CI/CD compatibility](#cicd-compatibility)
  - [SSM parameter verifications](#ssm-parameter-verifications)
- [Limitations](#limitations)
  - [config-file-type:s3](#config-file-types3)
- [References](#references)
  - [CloudPosse terraform-aws-ecs-container-definition](#cloudposse-terraform-aws-ecs-container-definition)
  - [awslogs](#awslogs)
  - [DataDog integration](#datadog-integration)
  - [AWS FireLens](#aws-firelens)
  - [Utilities](#utilities)
- [Requirements](#requirements)
- [Providers](#providers)
- [Modules](#modules)
- [Resources](#resources)
- [Inputs](#inputs)
- [Outputs](#outputs)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Description
Terraform module to generate well-formed JSON documents that are passed to the aws_ecs_task_definition Terraform resource
as [container definitions](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#container_definitions).
Wraps CloudPosse's module with additional features.

### Side-cars
Thr application container can be built with a DataDog APM binary and bundled with side-cars:
* DataDog monitoring agent (optional)
* AWS Firelens for log forwarding using a fluent-bit output plugin for DataDog or CloudWatch logs.

![](taskdef.png)

### CI/CD compatibility
For existing ECS tasks, CI/CD pipelines will create new revisions for each image built,
tagged and deployed to ECS. The terraform state will remain on the old task def revision and will revert ECS to old revision.
- When variable image_tag is set, the container image tag is 'hard-coded'. This is required for the initial creation of a ECS task definition.
- When variable image_tag is not set, the module will look up and reuse the image tag from the existing active task definition.

### SSM parameter verifications
SSM parameters are validated to avoid failing ECS deployments.
The values are parsed to find name part of SSM parameter ARNs only.

## Limitations
- AWS FireLens can be configured to ship logs directly to ElasticSearch, but this configuration is not implemented in this module yet.
- ECS can also look up secrets from Secrets Manager. This is not supported by module.

### config-file-type:s3

When customer DevOps use DataDog to correlate application logs with metrics,
it may introduce compliance issues not having all logs in CloudWatch.

Firelens is able to ship logs to
[multiple destinations](https://github.com/aws-samples/amazon-ecs-firelens-examples/tree/master/examples/fluent-bit/send-to-multiple-destinations).

HOWEVER, as
[stated](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_firelens.html#firelens-taskdef):
"For tasks using the Fargate launch type, the only supported
config-file-type value is file." **NOT config-file-type:s3.**

This means that custom configs must be added to a custom built docker
image. The custom fluent-bit config supports environment variables, so
that parameters for the DataDog and CloudWatch output plugins can be
altered across TEST/STAGE/PROD, but this demands a heap of moving pieces
and can be error prone.

## References

### CloudPosse terraform-aws-ecs-container-definition

- https://registry.terraform.io/modules/cloudposse/ecs-container-definition/aws/

### awslogs

- https://github.com/docker/docker.github.io/blob/master/config/containers/logging/awslogs.md
- https://github.com/aws/amazon-ecs-agent/issues/1192

### DataDog integration

- DataDog monitoring of ECS Fargate is configured according to
  https://docs.datadoghq.com/integrations/ecs_fargate/#web-ui
- About docker_labels, see
  https://docs.datadoghq.com/integrations/faq/integration-setup-ecs-fargate
- About Container Discovery Management, see
  https://docs.datadoghq.com/agent/autodiscovery/management/?tab=containerizedagent

### AWS FireLens

- https://aws.amazon.com/blogs/containers/under-the-hood-firelens-for-amazon-ecs-tasks
- https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_firelens.html
- https://docs.fluentbit.io/manual/output/datadog
- https://www.datadoghq.com/blog/multiline-logging-guide
- https://github.com/aws-samples/amazon-ecs-firelens-examples/blob/master/examples/fluent-bit/datadog/task-definition.json

### Utilities
- https://github.com/git-chglog/git-chglog
- https://github.com/pnikosis/semtag
- https://pre-commit.com/


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.34, < 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.34, < 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_datadog"></a> [datadog](#module\_datadog) | cloudposse/ecs-container-definition/aws | 0.56.0 |
| <a name="module_firelens"></a> [firelens](#module\_firelens) | cloudposse/ecs-container-definition/aws | 0.56.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/ecs-container-definition/aws | 0.56.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_cluster) | data source |
| [aws_ecs_container_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_container_definition) | data source |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_task_definition) | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_secretsmanager_secret.datadog_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret.secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_ssm_parameter.datadog_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.fluent_ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_log_group"></a> [cloudwatch\_log\_group](#input\_cloudwatch\_log\_group) | Name of the log group | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | ECS cluster name | `string` | n/a | yes |
| <a name="input_container_depends_on"></a> [container\_depends\_on](#input\_container\_depends\_on) | The dependencies defined for container startup and shutdown. A container can contain multiple dependencies. When a dependency is defined for container startup, for container shutdown it is reversed. The condition can be one of START, COMPLETE, SUCCESS or HEALTHY | <pre>list(object({<br>    containerName = string<br>    condition     = string<br>  }))</pre> | `null` | no |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | The name of container. Use when container name differs from service name | `string` | `""` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | The number of cpu units to reserve for the container. This is optional for tasks using Fargate launch type and the total amount of container\_cpu of all containers in a task will need to be lower than the task-level cpu value | `number` | `0` | no |
| <a name="input_datadog_agent_container_source"></a> [datadog\_agent\_container\_source](#input\_datadog\_agent\_container\_source) | https://docs.datadoghq.com/agent/docker/?tab=standard#misc | `string` | `"ecs_fargate"` | no |
| <a name="input_datadog_apm_enable"></a> [datadog\_apm\_enable](#input\_datadog\_apm\_enable) | When set to true, the Datadog Agent accepts trace metrics | `bool` | `true` | no |
| <a name="input_datadog_apm_ignore_resources"></a> [datadog\_apm\_ignore\_resources](#input\_datadog\_apm\_ignore\_resources) | Configure resources for the Agent to ignore. Format should be comma separated, regular expressions. Example: GET /ignore-me,(GET\|POST) /and-also-me. | `string` | `""` | no |
| <a name="input_datadog_container_exclude"></a> [datadog\_container\_exclude](#input\_datadog\_container\_exclude) | Blocklist of containers to exclude (separated by spaces). Use .* to exclude all. For example: "image:image\_name\_3 image:image\_name\_4" | `string` | `"name:datadog-agent name:firelens"` | no |
| <a name="input_datadog_docker_labels"></a> [datadog\_docker\_labels](#input\_datadog\_docker\_labels) | Docker labels used by DataDog agent for auto-discovery [doc](https://docs.datadoghq.com/agent/autodiscovery/basic_autodiscovery?tab=docker) | `map(string)` | `null` | no |
| <a name="input_datadog_domain"></a> [datadog\_domain](#input\_datadog\_domain) | The default public endpoint endpoint is in US | `string` | `"datadoghq.com"` | no |
| <a name="input_datadog_environment"></a> [datadog\_environment](#input\_datadog\_environment) | Customer environment variables used by DataDog agent [doc](https://docs.datadoghq.com/agent/docker/?tab=standard#environment-variables) | <pre>list(object({<br>    name  = string<br>    value = string<br>  }))</pre> | `[]` | no |
| <a name="input_datadog_image_url"></a> [datadog\_image\_url](#input\_datadog\_image\_url) | URL to datadog-agent docker image | `string` | `"datadog/agent:latest"` | no |
| <a name="input_datadog_log_level"></a> [datadog\_log\_level](#input\_datadog\_log\_level) | https://docs.datadoghq.com/agent/troubleshooting/debug_mode/?tab=agentv6v7#agent-log-level | `string` | `"WARN"` | no |
| <a name="input_datadog_logcollection_enable"></a> [datadog\_logcollection\_enable](#input\_datadog\_logcollection\_enable) | Monitor Fargate logs by using the AWS FireLens integration built on Datadogs Fluentbit output plugin to send logs to Datadog | `bool` | `true` | no |
| <a name="input_datadog_logcollection_source"></a> [datadog\_logcollection\_source](#input\_datadog\_logcollection\_source) | The source option will automatically trigger a log processing pipeline in Datadog for your integration [if available](https://docs.datadoghq.com/integrations/#cat-log-collection). | `string` | `"php"` | no |
| <a name="input_datadog_process_enable"></a> [datadog\_process\_enable](#input\_datadog\_process\_enable) | Enable the DataDog process agent | `bool` | `true` | no |
| <a name="input_datadog_secrets"></a> [datadog\_secrets](#input\_datadog\_secrets) | The SSM/SecretsManager parameter ARNs to pass to the datadog sidecar | <pre>list(object({<br>    name      = string<br>    valueFrom = string<br>  }))</pre> | `[]` | no |
| <a name="input_datadog_tags"></a> [datadog\_tags](#input\_datadog\_tags) | Map of tags sent to DataDog | `map` | `{}` | no |
| <a name="input_docker_labels"></a> [docker\_labels](#input\_docker\_labels) | The configuration options to send to the `docker_labels` of main container | `map(string)` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment variables to pass to the container | <pre>list(object({<br>    name  = string<br>    value = string<br>  }))</pre> | `null` | no |
| <a name="input_environment_files"></a> [environment\_files](#input\_environment\_files) | One or more files containing the environment variables to pass to the container. This maps to the --env-file option to docker run. The file must be hosted in Amazon S3. | <pre>list(object({<br>    value = string<br>    type  = string<br>  }))</pre> | `null` | no |
| <a name="input_healthcheck"></a> [healthcheck](#input\_healthcheck) | A map containing:<br>  command (string),<br>  timeout,<br>  interval (duration in seconds),<br>  retries (1-10, number of times to retry before marking container unhealthy),<br>  and startPeriod (0-300, optional grace period to wait, in seconds, before failed healthchecks count toward retries)<br><br>If Healthcheck is enabled, datadog sidecar will depend on application container having status HEALTHY.<br>https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerDependency.html | <pre>object({<br>    command     = list(string)<br>    retries     = number<br>    timeout     = number<br>    interval    = number<br>    startPeriod = number<br>  })</pre> | `null` | no |
| <a name="input_image_tag"></a> [image\_tag](#input\_image\_tag) | Docker image tag. Used to initiate new task definition from scratch using image:latest or when CI/CD processes does not update tags in container definitions. | `string` | `""` | no |
| <a name="input_linux_parameters"></a> [linux\_parameters](#input\_linux\_parameters) | Linux-specific modifications that are applied to the container, such as Linux kernel capabilities. For more details, see https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_LinuxParameters.html | <pre>object({<br>    capabilities = object({<br>      add  = list(string)<br>      drop = list(string)<br>    })<br>    devices = list(object({<br>      containerPath = string<br>      hostPath      = string<br>      permissions   = list(string)<br>    }))<br>    initProcessEnabled = bool<br>    maxSwap            = number<br>    sharedMemorySize   = number<br>    swappiness         = number<br>    tmpfs = list(object({<br>      containerPath = string<br>      mountOptions  = list(string)<br>      size          = number<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_logcollection_parsejson"></a> [logcollection\_parsejson](#input\_logcollection\_parsejson) | Parse container log output as JSON [doc](https://github.com/aws-samples/amazon-ecs-firelens-examples/tree/master/examples/fluent-bit/parse-json) | `bool` | `false` | no |
| <a name="input_map_environment"></a> [map\_environment](#input\_map\_environment) | The environment variables to pass to the container. This is a map of string: {key: value}, environment override map\_environment | `map(string)` | `null` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | The amount of memory (in MiB) to allow the container to use. This is a hard limit, if the container attempts to exceed the container\_memory, the container is killed. This field is optional for Fargate launch type and the total amount of container\_memory of all containers in a task will need to be lower than the task memory value | `number` | `null` | no |
| <a name="input_memory_reservation"></a> [memory\_reservation](#input\_memory\_reservation) | The amount of memory (in MiB) to reserve for the container. If container needs to exceed this threshold, it can do so up to the set container\_memory hard limit | `number` | `null` | no |
| <a name="input_mount_points"></a> [mount\_points](#input\_mount\_points) | Container mount points. This is a list of maps, where each map should contain a `containerPath` and `sourceVolume` | <pre>list(object({<br>    containerPath = string<br>    sourceVolume  = string<br>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the service. Up to 255 characters (a-z, A-Z, 0-9, -, \_ allowed) | `string` | n/a | yes |
| <a name="input_port_mappings"></a> [port\_mappings](#input\_port\_mappings) | The port mappings to configure for the container. This is a list of maps. Each map should contain "containerPort", "hostPort", and "protocol", where "protocol" is one of "tcp" or "udp". If using containers in a task with the awsvpc or host network mode, the hostPort can either be left blank or set to the same value as the containerPort | <pre>list(object({<br>    containerPort = number<br>    hostPort      = number<br>    protocol      = string<br>  }))</pre> | <pre>[<br>  {<br>    "containerPort": 80,<br>    "hostPort": 80,<br>    "protocol": "tcp"<br>  }<br>]</pre> | no |
| <a name="input_repo"></a> [repo](#input\_repo) | Docker repo | `string` | n/a | yes |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | The SSM/SecretsManager parameter ARNs to pass to the container | <pre>list(object({<br>    name      = string<br>    valueFrom = string<br>  }))</pre> | `[]` | no |
| <a name="input_ssm_datadog_api_key"></a> [ssm\_datadog\_api\_key](#input\_ssm\_datadog\_api\_key) | Path to SSM/SecretsManager parameter ARN storing the encrypted DataDog API key | `string` | `null` | no |
| <a name="input_task_definition_name"></a> [task\_definition\_name](#input\_task\_definition\_name) | The name of task definition. Use when task definition name differs from service name | `string` | `""` | no |
| <a name="input_volumes_from"></a> [volumes\_from](#input\_volumes\_from) | A list of VolumesFrom maps which contain "sourceContainer" (name of the container that has the volumes to mount) and "readOnly" (whether the container can write to the volume) | <pre>list(object({<br>    sourceContainer = string<br>    readOnly        = bool<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_json"></a> [json](#output\_json) | JSON encoded list of container definitions for use with other terraform resources such as aws\_ecs\_task\_definition |
| <a name="output_json_app_only"></a> [json\_app\_only](#output\_json\_app\_only) | JSON encoded list of container definition without DataDog side-car |
| <a name="output_json_objects_map"></a> [json\_objects\_map](#output\_json\_objects\_map) | Map of container definitions |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
