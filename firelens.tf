locals {

  ###
  # aws firelens with DataDog output plugin
  # https://docs.datadoghq.com/integrations/fluentbit/#configuration-parameters
  # https://docs.datadoghq.com/integrations/ecs_fargate/#fluent-bit-and-firelens
  # https://github.com/aws-samples/amazon-ecs-firelens-examples/tree/master/examples/fluent-bit/datadog
  # https://docs.fluentbit.io/manual/output/datadog

  # Fluentbit datadog output plugin tags config
  # dd_tags values are separated by comma
  # Spaces in values are replaced with underscore
  # Excluding github urls to avoid special characters
  # TODO: handle special chars in all tags
  # https://docs.fluentbit.io/manual/pipeline/outputs/datadog#configuration-file
  fb_tags = join(",", [for k, v in var.datadog_tags : "${k}:${v}" if k != "giturl"])

  avaliable_configuration = {
    firelens_datadog = {
      logDriver = "awsfirelens",

      options = {
        compress       = "gzip"
        dd_message_key = "log"
        dd_service     = var.name
        dd_source      = var.datadog_logcollection_source
        dd_tags        = local.fb_tags
        Host           = format("http-intake.logs.%s", var.datadog_domain)
        Name           = "datadog"
        provider       = "ecs"
        TLS            = "on"
      }

      secretOptions = [
        {
          name      = "apikey",
          valueFrom = var.ssm_datadog_api_key
      }]
    }

    ###
    # aws firelens with CloudWatch Logs output plugin
    # This plugin is bundled with the AWS Provided Fluent-Bit image
    # https://github.com/aws/amazon-cloudwatch-logs-for-fluent-bit
    # https://github.com/aws-samples/amazon-ecs-firelens-examples/blob/mainline/examples/fluent-bit/cloudwatchlogs/task-definition.json
    # Not to be confused with alternative plugin:
    # https://docs.fluentbit.io/manual/pipeline/outputs/cloudwatch

    firelens_cwl = {
      logDriver = "awsfirelens",
      options = {
        auto_create_group = true,
        log_group_name    = var.cloudwatch_log_group,
        log_key           = "log",
        log_stream_prefix = format("%s/", var.name),
        Name              = "cloudwatch",
        region            = data.aws_region.this.name,
      }
      secretOptions = []
    }


    firelens_s3 = {
      logDriver = "awsfirelens",
      options = {
        Name = "s3"
        "region" : data.aws_region.this.name,
        "bucket" : var.s3_bucket_name,
        "total_file_size" : "1M",
        "upload_timeout" : "1m",
        "use_put_object" : "On"
      }
    }

    firelens_kinesis = {
      "logDriver" : "awsfirelens",
      "options" : {
        "Name" : "kinesis_streams",
        "region" : data.aws_region.this.name,
        "stream" : var.kinesis_stream_name
      }
    }

    firelens_firehose = {
      "logDriver" : "awsfirelens",
      "options" : {
        "Name" : "firehose",
        "region" : data.aws_region.this.name,
        "delivery_stream" : var.firehose_stream_name
      }
    }
  }
  ###
  # Fluent-Bit Options

  fluentbit_options = {
    enable-ecs-log-metadata = "false",
  }

  # Parsing container stdout logs that are serialized JSON using bundled custom config
  # https://github.com/aws/aws-for-fluent-bit/blob/master/configs/parse-json.conf
  # https://github.com/aws-samples/amazon-ecs-firelens-examples/tree/mainline/examples/fluent-bit/parse-json
  fluentbit_options_json = {
    enable-ecs-log-metadata = "false",
    config-file-type        = "file",
    config-file-value       = "/fluent-bit/configs/parse-json.conf"
  }
}

# Locating regional ECR URI for AWS provided Fluent-Bit
# https://github.com/aws/aws-for-fluent-bit#amazon-ecr
data "aws_ssm_parameter" "fluent_ecr" {
  name = "/aws/service/aws-for-fluent-bit/stable"
}

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_firelens.html#firelens-using-fluentbit
module "firelens" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.58.3"

  container_cpu                = 0
  container_image              = nonsensitive(data.aws_ssm_parameter.fluent_ecr.value)
  container_memory             = null
  container_memory_reservation = 100
  container_name               = "firelens"
  environment                  = []
  essential                    = true
  mount_points                 = []
  port_mappings                = []
  user                         = 0
  volumes_from                 = []

  # fluentbit sidecar's own logs are sent to cloudwatch
  log_configuration = {
    logDriver = "awslogs",
    options = {
      awslogs-datetime-format = "\\[%Y/%m/%d %H:%M:%S\\]",
      awslogs-group           = var.cloudwatch_log_group,
      awslogs-region          = data.aws_region.this.name,
      awslogs-stream-prefix   = var.name,
    }
    secretOptions = []
  }

  # TODO: support for multi-line outputs like stacktraces
  # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-ecs-taskdefinition-firelensconfiguration.html
  firelens_configuration = {
    type = "fluentbit",
    options = (var.logcollection_parsejson ?
      local.fluentbit_options_json :
      local.fluentbit_options
    )
  }
}
