
<a name="v0.15.0"></a>
## [v0.15.0](https://github.com/basefarm/terraform-aws-bf-ecs-container-definition/compare/v0.14.0...v0.15.0) (2022-01-06)

### Bug Fixes

* versions.tf update.
* Changed datadog log collection to not be enabled by default.
* Updated dependencies
* Fixed "mount_points" variable, was missing a required "readOnly" parameter


<a name="v0.14.0"></a>
## [v0.14.0](https://github.com/basefarm/terraform-aws-ecs-container-definition/compare/v0.13.0...v0.14.0) (2021-09-03)

### Bug Fixes

* using firelens/stable release [#3](https://github.com/basefarm/terraform-aws-ecs-container-definition/issues/3)


<a name="v0.13.0"></a>
## [v0.13.0](https://github.com/basefarm/terraform-aws-ecs-container-definition/compare/v0.12.0...v0.13.0) (2021-07-01)

### Bug Fixes

* Container definition planned with sensitive diff [#2](https://github.com/basefarm/terraform-aws-ecs-container-definition/issues/2)

### Features

* upstream variable map_secrets


<a name="v0.12.0"></a>
## [v0.12.0](https://github.com/basefarm/terraform-aws-ecs-container-definition/compare/v0.11.0...v0.12.0) (2021-04-19)

### Code Refactoring

* aws provider required is 3.34 for ECS Exec support


<a name="v0.11.0"></a>
## [v0.11.0](https://github.com/basefarm/terraform-aws-ecs-container-definition/compare/v0.10.0...v0.11.0) (2021-04-19)

### Features

* support for linux_parameters


<a name="v0.10.0"></a>
## [v0.10.0](https://github.com/basefarm/terraform-aws-ecs-container-definition/compare/v0.9.0...v0.10.0) (2020-12-10)

### Features

* variable essential


<a name="v0.9.0"></a>
## [v0.9.0](https://github.com/basefarm/terraform-aws-ecs-container-definition/compare/v0.8.0...v0.9.0) (2020-12-04)

### Code Refactoring

* sub-module version bump for tf 0.14 support
* looser terraform version restrictions


<a name="v0.8.0"></a>
## [v0.8.0](https://github.com/basefarm/terraform-aws-ecs-container-definition/compare/v0.7.0...v0.8.0) (2020-11-20)

### Code Refactoring

* secrets variables default []
* cloudwatch_log_group as required var

### Documentation

* pre-commit url
* added utility links


<a name="v0.7.0"></a>
## [v0.7.0](https://github.com/basefarm/terraform-aws-ecs-container-definition/compare/v0.6.0...v0.7.0) (2020-11-16)


<a name="v0.6.0"></a>
## [v0.6.0](https://github.com/basefarm/terraform-aws-ecs-container-definition/compare/v0.5.0...v0.6.0) (2020-11-06)

### Code Refactoring

* Using cloudposse module version 0.44

### Documentation

* changelog

### Features

* Support for environmentFiles


<a name="v0.5.0"></a>
## [v0.5.0](https://github.com/basefarm/terraform-aws-ecs-container-definition/compare/v0.4.0...v0.5.0) (2020-10-27)

### Documentation

* changelog

### Features

* attempt on unified datadog service tagging.


<a name="v0.4.0"></a>
## [v0.4.0](https://github.com/basefarm/terraform-aws-ecs-container-definition/compare/v0.3.0...v0.4.0) (2020-10-12)

### Features

* variable for datadog endpoint feat: variable for datadog docker image url feat: variable for container dependencies feat: gzipped datadog log output remove: deprecated image filtering not working for ECS wip: avoid empty values in awsfirelens options map - specifically datadog_tags


<a name="v0.3.0"></a>
## [v0.3.0](https://github.com/basefarm/terraform-aws-ecs-container-definition/compare/v0.2.0...v0.3.0) (2020-09-23)

### Features

* container name override


<a name="v0.2.0"></a>
## [v0.2.0](https://github.com/basefarm/terraform-aws-ecs-container-definition/compare/v0.1.0...v0.2.0) (2020-08-26)

### Code Refactoring

* looser aws provider version restrictions

### Documentation

* chglog update


<a name="v0.1.0"></a>
## v0.1.0 (2020-08-26)

### Documentation

* module doc

### Features

* initial module

