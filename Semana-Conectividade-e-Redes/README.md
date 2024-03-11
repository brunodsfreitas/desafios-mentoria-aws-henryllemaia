## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.39.1 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_TaskDefinition_Application"></a> [TaskDefinition\_Application](#module\_TaskDefinition\_Application) | ./modules/taskdefinition_app | n/a |
| <a name="module_TaskDefinition_Database"></a> [TaskDefinition\_Database](#module\_TaskDefinition\_Database) | ./modules/taskdefinition_db | n/a |
| <a name="module_ecrRepo"></a> [ecrRepo](#module\_ecrRepo) | ./modules/ecr | n/a |
| <a name="module_ecsCluster"></a> [ecsCluster](#module\_ecsCluster) | ./modules/ecs | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_config_db_host"></a> [app\_config\_db\_host](#input\_app\_config\_db\_host) | Endereço do serviço de banco de dados | `string` | `"postgres"` | no |
| <a name="input_app_config_db_port"></a> [app\_config\_db\_port](#input\_app\_config\_db\_port) | Porta do Banco de dados | `number` | `5432` | no |
| <a name="input_app_config_db_pwd"></a> [app\_config\_db\_pwd](#input\_app\_config\_db\_pwd) | Senha do usuário do banco de dados | `string` | `"postgres"` | no |
| <a name="input_app_config_db_user"></a> [app\_config\_db\_user](#input\_app\_config\_db\_user) | Nome do usuário do banco de dados | `string` | `"postgres"` | no |
| <a name="input_application_container_port"></a> [application\_container\_port](#input\_application\_container\_port) | Porta da Aplicação da Task Definition | `number` | `null` | no |
| <a name="input_asg_health_check_type"></a> [asg\_health\_check\_type](#input\_asg\_health\_check\_type) | Tipo do HealthCheck (Autoscaling Group) | `string` | `"ELB"` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | Lista das Zonas de Disponibilidades para o projeto | `list(string)` | `null` | no |
| <a name="input_cidr_block_vpc"></a> [cidr\_block\_vpc](#input\_cidr\_block\_vpc) | CIDR da VPC do Projeto | `string` | `null` | no |
| <a name="input_cidr_blocks_subnets"></a> [cidr\_blocks\_subnets](#input\_cidr\_blocks\_subnets) | Lista de CIDR de Subnets para o projeto | `list(string)` | `null` | no |
| <a name="input_db_application_container_port"></a> [db\_application\_container\_port](#input\_db\_application\_container\_port) | Porta da Aplicação da Task Definition | `number` | `null` | no |
| <a name="input_db_ecs_task_execution_role_name"></a> [db\_ecs\_task\_execution\_role\_name](#input\_db\_ecs\_task\_execution\_role\_name) | IAM Role para execução da Task Definition | `string` | `null` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Nome do banco de dados | `string` | `"postgres"` | no |
| <a name="input_db_password"></a> [db\_password](#input\_db\_password) | Senha do usuário do banco de dados | `string` | `"postgres"` | no |
| <a name="input_db_service_name"></a> [db\_service\_name](#input\_db\_service\_name) | Nome do Serviço para rodar no Cluster | `string` | `"servico"` | no |
| <a name="input_db_target_group_name"></a> [db\_target\_group\_name](#input\_db\_target\_group\_name) | Nome do Target Group | `string` | `"TG"` | no |
| <a name="input_db_td_cpu"></a> [db\_td\_cpu](#input\_db\_td\_cpu) | Quantidade de CPU a ser alocada pela Task Definition | `number` | `256` | no |
| <a name="input_db_td_memory"></a> [db\_td\_memory](#input\_db\_td\_memory) | Quantidade em MB de mémoria a ser alocada pela Task Definition | `number` | `256` | no |
| <a name="input_db_td_task_family"></a> [db\_td\_task\_family](#input\_db\_td\_task\_family) | Nome (family) da Task Definition | `string` | `null` | no |
| <a name="input_db_td_task_name"></a> [db\_td\_task\_name](#input\_db\_td\_task\_name) | Nome da Task Definition | `string` | `"TD"` | no |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | Nome do usuário do banco de dados | `string` | `"postgres"` | no |
| <a name="input_desc_tags"></a> [desc\_tags](#input\_desc\_tags) | Tags Globais do Projeto | `map(string)` | `null` | no |
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity) | Quantidade desejada de EC2 (Autoscaling Group) | `number` | `1` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | Zone ID do registro de DNS Route53 | `string` | `null` | no |
| <a name="input_ecr_repo_name"></a> [ecr\_repo\_name](#input\_ecr\_repo\_name) | Nome do repositório ECR | `string` | `null` | no |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | Nome do Cluster ECS | `string` | `"Projeto"` | no |
| <a name="input_ecs_task_execution_role_name"></a> [ecs\_task\_execution\_role\_name](#input\_ecs\_task\_execution\_role\_name) | IAM Role para execução da Task Definition | `string` | `null` | no |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | IAM Instance Profile que será atribuida na EC2 | `string` | `null` | no |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | Image-ID (AMI) que será usada para subir as EC2 | `string` | `"ami-0f6000d4563f2c95f"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Tipo de Instância que será usada para subir EC2 | `string` | `"t2.micro"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | Chave PEM para uso na autenticação com a EC2 | `string` | `null` | no |
| <a name="input_load_balancer_name"></a> [load\_balancer\_name](#input\_load\_balancer\_name) | Nome do Load Balancer | `string` | `"LB"` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | Quantidade Máxima de EC2 (Autoscaling Group) | `number` | `2` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | Quantidade Mínima de EC2 (Autoscaling Group) | `number` | `1` | no |
| <a name="input_profile"></a> [profile](#input\_profile) | Definição do AWS Profile | `string` | `"default"` | no |
| <a name="input_region"></a> [region](#input\_region) | Definição da Região | `string` | `"us-east-2"` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Nome do Serviço para rodar no Cluster | `string` | `"servico"` | no |
| <a name="input_target_group_name"></a> [target\_group\_name](#input\_target\_group\_name) | Nome do Target Group | `string` | `"TG"` | no |
| <a name="input_td_cpu"></a> [td\_cpu](#input\_td\_cpu) | Quantidade de CPU a ser alocada pela Task Definition | `number` | `256` | no |
| <a name="input_td_memory"></a> [td\_memory](#input\_td\_memory) | Quantidade em MB de mémoria a ser alocada pela Task Definition | `number` | `256` | no |
| <a name="input_td_task_family"></a> [td\_task\_family](#input\_td\_task\_family) | Nome (family) da Task Definition | `string` | `null` | no |
| <a name="input_td_task_name"></a> [td\_task\_name](#input\_td\_task\_name) | Nome da Task Definition | `string` | `"TD"` | no |

## Outputs

No outputs.
