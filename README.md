# Дипломная работа netology

## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

### Создание облачной инфраструктуры  

Backend для Terraform будет храниться в S3 bucket. Для работы с бакетом используется отдельная сервисная учетка с ролью 
`storage.editor`.  
Конфиг [backend.tf](src/terraform/backend.tf):  
```terraform
terraform {
  backend "s3" {
    endpoint                    = "storage.yandexcloud.net"
    bucket                      = "belas80-tf-states-netology"
    key                         = "main/terraform.tfstate"
    region                      = "ru-central1"
    profile                     = "netology"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
```

Выполнение первоначальной инициализации:  
```shell
% terraform init             

Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Reusing previous version of yandex-cloud/yandex from the dependency lock file
- Installing yandex-cloud/yandex v0.82.0...
- Installed yandex-cloud/yandex v0.82.0 (unauthenticated)

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

Создание workspaces:  
```shell
% terraform workspace new stage
Created and switched to workspace "stage"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.

% terraform workspace new prod 
Created and switched to workspace "prod"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.

% terraform workspace list
  default
* prod
  stage
```

Проверка что появилось в бакете S3:  
```shell
% aws s3 --endpoint-url=https://storage.yandexcloud.net ls s3://belas80-tf-states-netology/ --recursive --profile netology 
2022-11-22 16:08:37        180 env:/prod/main/terraform.tfstate
2022-11-22 16:08:31        180 env:/stage/main/terraform.tfstate
```

VPC с подсетями в разных зонах доступности определен в файле [network.tf](src/terraform/network.tf)  
Проверка созадния ресурсов:  
```shell
% terraform apply -auto-approve
...
...
Plan: 4 to add, 0 to change, 0 to destroy.
yandex_vpc_network.lab-net: Creating...
yandex_vpc_network.lab-net: Creation complete after 3s [id=enpgbe7428ah9f32cu1p]
yandex_vpc_subnet.private-c: Creating...
yandex_vpc_subnet.private-b: Creating...
yandex_vpc_subnet.private-a: Creating...
yandex_vpc_subnet.private-c: Creation complete after 0s [id=b0c3gum86823igdo6v0g]
yandex_vpc_subnet.private-a: Creation complete after 1s [id=e9b34nrmpufvc5ub0l8g]
yandex_vpc_subnet.private-b: Creation complete after 2s [id=e2ldjqg488qn0dc93ao7]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
```
Проверка удаления ресурсов:  
```shell
% terraform destroy -auto-approve
...
...
Plan: 0 to add, 0 to change, 4 to destroy.
yandex_vpc_subnet.private-b: Destroying... [id=e2ldjqg488qn0dc93ao7]
yandex_vpc_subnet.private-c: Destroying... [id=b0c3gum86823igdo6v0g]
yandex_vpc_subnet.private-a: Destroying... [id=e9b34nrmpufvc5ub0l8g]
yandex_vpc_subnet.private-b: Destruction complete after 2s
yandex_vpc_subnet.private-c: Destruction complete after 5s
yandex_vpc_subnet.private-a: Destruction complete after 6s
yandex_vpc_network.lab-net: Destroying... [id=enpgbe7428ah9f32cu1p]
yandex_vpc_network.lab-net: Destruction complete after 1s

Destroy complete! Resources: 4 destroyed.
```

