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
| <a name="module_application_qrcode"></a> [application\_qrcode](#module\_application\_qrcode) | ./modules/application_qrcode | n/a |
| <a name="module_application_tosios"></a> [application\_tosios](#module\_application\_tosios) | ./modules/application_tosios | n/a |
| <a name="module_core_infrastructure"></a> [core\_infrastructure](#module\_core\_infrastructure) | ./modules/core_infrastructure | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_qrcode_target_group_arn"></a> [app\_qrcode\_target\_group\_arn](#input\_app\_qrcode\_target\_group\_arn) | target group | `string` | `null` | no |
| <a name="input_application_container_port"></a> [application\_container\_port](#input\_application\_container\_port) | Porta da Aplicação da Task Definition | `number` | `null` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | Lista das Zonas de Disponibilidades para o projeto | `list(string)` | `null` | no |
| <a name="input_cidr_block_vpc"></a> [cidr\_block\_vpc](#input\_cidr\_block\_vpc) | CIDR da VPC do Projeto | `string` | `null` | no |
| <a name="input_cidr_blocks_subnets"></a> [cidr\_blocks\_subnets](#input\_cidr\_blocks\_subnets) | Lista de CIDR de Subnets para o projeto | `list(string)` | `null` | no |
| <a name="input_desc_tags"></a> [desc\_tags](#input\_desc\_tags) | Tags Globais do Projeto | `map(string)` | `null` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | Zone ID do registro de DNS Route53 | `string` | `null` | no |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | Nome do Cluster ECS | `string` | `"Projeto"` | no |
| <a name="input_ecs_task_execution_role_name"></a> [ecs\_task\_execution\_role\_name](#input\_ecs\_task\_execution\_role\_name) | IAM Role para execução da Task Definition | `string` | `null` | no |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | IAM Instance Profile que será atribuida na EC2 | `string` | `null` | no |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | Image-ID (AMI) que será usada para subir as EC2 | `string` | `"ami-0f6000d4563f2c95f"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Tipo de Instância que será usada para subir EC2 | `string` | `"t2.micro"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | Chave PEM para uso na autenticação com a EC2 | `string` | `null` | no |
| <a name="input_load_balancer_name"></a> [load\_balancer\_name](#input\_load\_balancer\_name) | Nome do Load Balancer | `string` | `"LB"` | no |
| <a name="input_profile"></a> [profile](#input\_profile) | Definição do AWS Profile | `string` | `"default"` | no |
| <a name="input_region"></a> [region](#input\_region) | Definição da Região | `string` | `"us-east-2"` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Nome do Serviço para rodar no Cluster | `string` | `"servico"` | no |
| <a name="input_target_group_name"></a> [target\_group\_name](#input\_target\_group\_name) | Nome do Target Group | `string` | `"TG"` | no |
| <a name="input_td_cpu"></a> [td\_cpu](#input\_td\_cpu) | Quantidade de CPU a ser alocada pela Task Definition | `number` | `256` | no |
| <a name="input_td_memory"></a> [td\_memory](#input\_td\_memory) | Quantidade em MB de mémoria a ser alocada pela Task Definition | `number` | `256` | no |
| <a name="input_td_task_family"></a> [td\_task\_family](#input\_td\_task\_family) | Nome (family) da Task Definition | `string` | `null` | no |
| <a name="input_td_task_name"></a> [td\_task\_name](#input\_td\_task\_name) | Nome da Task Definition | `string` | `"TD"` | no |
| <a name="input_tosios_application_container_port"></a> [tosios\_application\_container\_port](#input\_tosios\_application\_container\_port) | Porta da Aplicação da Task Definition | `number` | `null` | no |
| <a name="input_tosios_ecs_task_execution_role_name"></a> [tosios\_ecs\_task\_execution\_role\_name](#input\_tosios\_ecs\_task\_execution\_role\_name) | IAM Role para execução da Task Definition | `string` | `null` | no |
| <a name="input_tosios_service_name"></a> [tosios\_service\_name](#input\_tosios\_service\_name) | Nome do Serviço para rodar no Cluster | `string` | `"servico"` | no |
| <a name="input_tosios_target_group_name"></a> [tosios\_target\_group\_name](#input\_tosios\_target\_group\_name) | Nome do Target Group | `string` | `"TG"` | no |
| <a name="input_tosios_td_cpu"></a> [tosios\_td\_cpu](#input\_tosios\_td\_cpu) | Quantidade de CPU a ser alocada pela Task Definition | `number` | `256` | no |
| <a name="input_tosios_td_memory"></a> [tosios\_td\_memory](#input\_tosios\_td\_memory) | Quantidade em MB de mémoria a ser alocada pela Task Definition | `number` | `256` | no |
| <a name="input_tosios_td_task_family"></a> [tosios\_td\_task\_family](#input\_tosios\_td\_task\_family) | Nome (family) da Task Definition | `string` | `null` | no |
| <a name="input_tosios_td_task_name"></a> [tosios\_td\_task\_name](#input\_tosios\_td\_task\_name) | Nome da Task Definition | `string` | `"TD"` | no |

## Outputs

No outputs.
