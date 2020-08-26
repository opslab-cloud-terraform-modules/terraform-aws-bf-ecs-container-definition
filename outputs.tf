output "json" {
  description = "JSON encoded list of container definitions for use with other terraform resources such as aws_ecs_task_definition"
  value = format("[ %s, %s, %s ]",
    module.this.json_map_encoded,
    module.firelens.json_map_encoded,
    module.datadog.json_map_encoded,
  )
}

output "json_app_only" {
  description = "JSON encoded list of container definition without DataDog side-car"
  value = format("[ %s, %s ]",
    module.this.json_map_encoded,
    module.firelens.json_map_encoded,
  )
}
