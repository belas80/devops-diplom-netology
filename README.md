# Дипломная работа netology

  * [Цели:](#цели)
  * [Этапы выполнения:](#этапы-выполнения)
     * [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
     * [Создание Kubernetes кластера](#создание-kubernetes-кластера)
     * [Создание тестового приложения](#создание-тестового-приложения)
     * [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
     * [Установка и настройка CI/CD](#установка-и-настройка-cicd)

## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

## Этапы выполнения:  

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

### Создание Kubernetes кластера  

Для создания кластера подготовим две инстанс группы, для Control Plane  [instance-group-cp.tf](src/terraform/instance-group-cp.tf) 
и для рабочих нод [instance-group-nodes.tf](src/terraform/instance-group-nodes.tf). Количесво хостов будет зависить от текущего воркспейса, которые определены в [variables.tf](src/terraform/variables.tf#L13).
Для воркспейса `stage` будет одна control plane и две рабочих ноды, а для `prod` будет 3 control plane и 3 рабочих ноды.  
Кластер будет в приватной сети, доступ к инетрету организован через nat ([instance-nat.tf](src/terraform/instance-nat.tf)) в отдельной публичной сети.
Так же этот инстанс будет использован в качестве бастиона для разворачивания k8s.  
Подготовим network load balancer для доступа к нашим contor plane по внешнему IP адресу [balancer-cp.tf](src/terraform/balancer-cp.tf).  
  
После применения конфигурации terraform, задеплоим k8s с помощью kubespray. Для этого подготовим файл интвентори с помощью bash скрипта [gen_k8s_inventory.sh](src/terraform/gen_k8s_inventory.sh).
Скрипт выведет в стандартный вывод значения из output терраформа, а мы перенаправим их нужное нам место, например:  
```shell
./gen_k8s_inventory.sh > ~/netology/kubespray2/inventory/mycluster/inventory.ini
```
Пример готового инвернтори [inventory.ini](src/kubespray_inventory/inventory.ini).  
Этого достаточно для деплоя:  
```shell
ansible-playbook -i inventory/mycluster/inventory.ini --become cluster.yml
```
После того как кластер k8s развернется, скопируем конфиг kubectl с любой control plane ноды себе на компьютер и поменяем IP кластера в нем на внешний адрес нашего load balancer для мастеров.
С помощью скрипта bash [get_k8s_config.sh](src/terraform/get_k8s_config.sh), конфиг по умолчнанию скопируется в домашнюю директорию `~/.kube/config`  
```shell
./get_k8s_config.sh
```
  
Результат:  

```shell
# Инстансы
 % yc compute instance list
+----------------------+-------+---------------+---------+--------------+---------------+
|          ID          | NAME  |    ZONE ID    | STATUS  | EXTERNAL IP  |  INTERNAL IP  |
+----------------------+-------+---------------+---------+--------------+---------------+
| ef3e6ujbvvn0ll9pjobd | node2 | ru-central1-c | RUNNING |              | 192.168.22.34 |
| epd1gum2c9l6lq5tjkpa | node1 | ru-central1-b | RUNNING |              | 192.168.21.9  |
| epdg9utmmrgbsfdi49lb | cp1   | ru-central1-b | RUNNING |              | 192.168.21.35 |
| fhmkbs1093990h4ekcel | nat   | ru-central1-a | RUNNING | 62.84.113.20 | 192.168.1.254 |
+----------------------+-------+---------------+---------+--------------+---------------+

# Инстанс группы
% yc compute instance-group list
+----------------------+----------+--------+------+
|          ID          |   NAME   | STATUS | SIZE |
+----------------------+----------+--------+------+
| cl1fi52qrsh3q6bajpnj | ig-cp    | ACTIVE |    1 |
| cl1i8hv2a46usa922oc5 | ig-nodes | ACTIVE |    2 |
+----------------------+----------+--------+------+

# Балансеры
 % yc load-balancer network-load-balancer list
+----------------------+---------------------+-------------+----------+----------------+------------------------+--------+
|          ID          |        NAME         |  REGION ID  |   TYPE   | LISTENER COUNT | ATTACHED TARGET GROUPS | STATUS |    
+----------------------+---------------------+-------------+----------+----------------+------------------------+--------+
| enpn9nn9itamve6tegn3 | nodes-load-balancer | ru-central1 | EXTERNAL |              1 | enpmket4ec55hi2pvjeu   | ACTIVE |
| enpr0826t77sdiea3kma | cp-load-balancer    | ru-central1 | EXTERNAL |              1 | enp4r73r93obl16cjkqn   | ACTIVE |
+----------------------+---------------------+-------------+----------+----------------+------------------------+--------+

# Таргет группа
% yc load-balancer network-load-balancer target-states --name=cp-load-balancer --target-group-id=enp4r73r93obl16cjkqn
+----------------------+---------------+---------+
|      SUBNET ID       |    ADDRESS    | STATUS  |
+----------------------+---------------+---------+
| e2lr7amvqvpjugas5sqa | 192.168.21.35 | HEALTHY |
+----------------------+---------------+---------+

% yc load-balancer network-load-balancer target-states --name=nodes-load-balancer --target-group-id=enpmket4ec55hi2pvjeu
+----------------------+---------------+---------+
|      SUBNET ID       |    ADDRESS    | STATUS  |
+----------------------+---------------+---------+
| b0c9jirv06s7v1sit00k | 192.168.22.34 | HEALTHY |
| e2lr7amvqvpjugas5sqa | 192.168.21.9  | HEALTHY |
+----------------------+---------------+---------+

# IP нашего балансировщика к мастерам
% terraform output -json lb_cp_external_ip
[[["51.250.94.150"]]]

# Копируем конфиг kubectl и проверяем работу k8s
% ./get_k8s_config.sh 

% kubectl cluster-info 
Kubernetes control plane is running at https://51.250.94.150:6443

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

% kubectl get nodes 
NAME    STATUS   ROLES           AGE    VERSION
cp1     Ready    control-plane   140m   v1.25.4
node1   Ready    <none>          139m   v1.25.4
node2   Ready    <none>          139m   v1.25.4
```

### Создание тестового приложения  

Репозиторий с простым nginx конфигом, dockerfile и html страничкой [здесь](https://github.com/belas80/myapp.git)
Регистр с собранным docker image [здесь](https://hub.docker.com/r/belas80/myapp/tags)

### Подготовка cистемы мониторинга и деплой приложения  

