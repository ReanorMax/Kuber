# AWX Deployment Guide

## Обзор

AWX (Ansible Tower open-source) - это веб-интерфейс для управления Ansible playbooks, инвентарем и автоматизацией. В данном руководстве описывается развертывание AWX в Kubernetes кластере Kind.

## Что такое AWX?

AWX предоставляет:
- **Веб-интерфейс** для управления Ansible
- **Job Templates** - шаблоны для запуска playbooks
- **Inventory Management** - управление инвентарем серверов
- **Credential Management** - безопасное хранение учетных данных
- **Scheduling** - планировщик задач
- **RBAC** - управление доступом на основе ролей

## Архитектура AWX в Kubernetes

AWX состоит из следующих компонентов:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   AWX Web       │    │   AWX Task      │    │   PostgreSQL    │
│   (Frontend)    │    │   (Worker)      │    │   (Database)    │
│                 │    │                 │    │                 │
│ - Web UI        │    │ - Job Execution │    │ - Data Storage  │
│ - API Server    │    │ - Playbook Runs │    │ - Configuration │
│ - Authentication│    │ - Background    │    │ - User Data     │
│                 │    │   Tasks         │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   AWX Operator  │
                    │   (Controller)  │
                    │                 │
                    │ - Manages AWX   │
                    │ - Handles CRDs  │
                    │ - Orchestrates  │
                    │   Components    │
                    └─────────────────┘
```

## Развертывание AWX

### 1. Создание Namespace

```bash
kubectl create namespace awx
```

### 2. Установка AWX Operator

```bash
# Клонируем репозиторий AWX Operator
git clone https://github.com/ansible/awx-operator.git
cd awx-operator

# Устанавливаем Operator
make deploy
```

### 3. Создание Secret с паролем администратора

```bash
kubectl create secret generic awx-admin-password \
  --from-literal=password='AWXadmin123!' \
  -n awx
```

### 4. Развертывание AWX Instance

Создаем манифест `awx-instance.yaml`:

```yaml
---
apiVersion: awx.ansible.com/v1beta1
kind: AWX
metadata:
  name: awx
  namespace: awx
spec:
  # Сервис типа NodePort для доступа извне
  service_type: NodePort
  nodeport_port: 30800
  
  # Hostname для AWX
  hostname: awx.local
  
  # Persistent storage для проектов
  projects_persistence: true
  projects_storage_size: 8Gi
  projects_storage_access_mode: ReadWriteOnce
  
  # Admin пользователь
  admin_user: admin
  admin_password_secret: awx-admin-password
  
  # Ресурсы для web контейнера
  web_resource_requirements:
    requests:
      cpu: 250m
      memory: 512Mi
    limits:
      cpu: 1000m
      memory: 2Gi
  
  # Ресурсы для task контейнера
  task_resource_requirements:
    requests:
      cpu: 250m
      memory: 512Mi
    limits:
      cpu: 1000m
      memory: 2Gi
  
  # PostgreSQL ресурсы
  postgres_resource_requirements:
    requests:
      cpu: 250m
      memory: 512Mi
    limits:
      cpu: 500m
      memory: 1Gi
  
  postgres_storage_requirements:
    requests:
      storage: 8Gi
```

Применяем манифест:

```bash
kubectl apply -f awx-instance.yaml
```

### 5. Проверка развертывания

```bash
# Проверяем статус AWX resource
kubectl get awx -n awx

# Проверяем Pod'ы
kubectl get pods -n awx

# Проверяем сервисы
kubectl get svc -n awx
```

## Доступ к AWX

### Через NodePort

AWX доступен на порту 30800:

- **URL**: `http://<SERVER_IP>:30800`
- **Логин**: `admin`
- **Пароль**: `AWXadmin123!`

### Через Ingress (рекомендуется)

Для продакшена рекомендуется настроить Ingress с SSL:

```yaml
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: awx-ingress
  namespace: awx
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
spec:
  tls:
  - hosts:
    - awx.local
    secretName: awx-tls
  rules:
  - host: awx.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: awx-service
            port:
              number: 80
```

## Использование AWX для развертывания на внешних серверах

### 1. Создание Inventory

1. Заходим в AWX веб-интерфейс
2. Переходим в **Inventories** → **Add**
3. Создаем новый inventory с серверами

### 2. Добавление Credentials

1. Переходим в **Credentials** → **Add**
2. Выбираем тип:
   - **Machine** - для SSH доступа
   - **Source Control** - для Git репозиториев
   - **Vault** - для Ansible Vault

### 3. Создание Project

1. Переходим в **Projects** → **Add**
2. Указываем:
   - **Name**: название проекта
   - **Source Control Type**: Git
   - **Source Control URL**: URL репозитория с playbooks
   - **Credentials**: учетные данные для Git

### 4. Создание Job Template

1. Переходим в **Templates** → **Add**
2. Выбираем тип **Job Template**
3. Настраиваем:
   - **Name**: название шаблона
   - **Job Type**: Run
   - **Inventory**: выбранный inventory
   - **Project**: выбранный проект
   - **Playbook**: путь к playbook файлу
   - **Credentials**: учетные данные

### 5. Запуск Job

1. Переходим в **Jobs**
2. Нажимаем **Launch** на нужном Job Template
3. Мониторим выполнение в реальном времени

## Примеры использования

### Развертывание веб-приложения

```yaml
# playbook.yml
---
- name: Deploy Web Application
  hosts: web_servers
  become: yes
  tasks:
    - name: Install Nginx
      package:
        name: nginx
        state: present
    
    - name: Copy web files
      copy:
        src: /path/to/web/files
        dest: /var/www/html/
    
    - name: Start Nginx
      service:
        name: nginx
        state: started
        enabled: yes
```

### Обновление системы

```yaml
# update-system.yml
---
- name: Update System Packages
  hosts: all
  become: yes
  tasks:
    - name: Update package cache
      package:
        update_cache: yes
    
    - name: Upgrade packages
      package:
        upgrade: yes
```

## Мониторинг и логирование

### Просмотр логов

```bash
# Логи AWX Web
kubectl logs -n awx deployment/awx-web

# Логи AWX Task
kubectl logs -n awx deployment/awx-task

# Логи PostgreSQL
kubectl logs -n awx statefulset/awx-postgres
```

### Мониторинг ресурсов

```bash
# Использование ресурсов Pod'ами
kubectl top pods -n awx

# Детальная информация о ресурсах
kubectl describe pods -n awx
```

## Troubleshooting

### Проблемы с ресурсами

Если Pod'ы не запускаются из-за нехватки ресурсов:

1. Проверьте доступные ресурсы:
```bash
kubectl describe node
```

2. Уменьшите требования в манифесте AWX:
```yaml
web_resource_requirements:
  requests:
    cpu: 50m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 1Gi
```

### Проблемы с базой данных

Если AWX не может подключиться к PostgreSQL:

1. Проверьте статус PostgreSQL:
```bash
kubectl get pods -n awx | grep postgres
```

2. Проверьте логи PostgreSQL:
```bash
kubectl logs -n awx statefulset/awx-postgres
```

### Проблемы с миграциями

Если init контейнер застрял на миграциях:

1. Проверьте логи init контейнера:
```bash
kubectl logs -n awx <task-pod-name> -c init-database
```

2. Перезапустите AWX:
```bash
kubectl delete awx awx -n awx
kubectl apply -f awx-instance.yaml
```

## Безопасность

### Рекомендации по безопасности

1. **Используйте сильные пароли** для admin пользователя
2. **Настройте RBAC** для ограничения доступа
3. **Используйте HTTPS** в продакшене
4. **Регулярно обновляйте** AWX до последней версии
5. **Мониторьте логи** на предмет подозрительной активности

### Настройка RBAC

```yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: awx-user
  namespace: awx
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list"]
```

## Масштабирование

### Горизонтальное масштабирование

Для увеличения количества worker'ов:

```yaml
spec:
  task_replicas: 3  # Увеличиваем количество task Pod'ов
```

### Вертикальное масштабирование

Для увеличения ресурсов:

```yaml
spec:
  web_resource_requirements:
    requests:
      cpu: 500m
      memory: 1Gi
    limits:
      cpu: 2000m
      memory: 4Gi
```

## Резервное копирование

### Backup базы данных

```bash
# Создание backup
kubectl exec -n awx awx-postgres-15-0 -- pg_dump -U awx awx > awx-backup.sql

# Восстановление из backup
kubectl exec -i -n awx awx-postgres-15-0 -- psql -U awx awx < awx-backup.sql
```

### Backup конфигурации

```bash
# Backup AWX resource
kubectl get awx awx -n awx -o yaml > awx-config-backup.yaml

# Backup всех ресурсов namespace
kubectl get all -n awx -o yaml > awx-namespace-backup.yaml
```

## Заключение

AWX в Kubernetes предоставляет мощную платформу для автоматизации и управления инфраструктурой. Следуя данному руководству, вы сможете:

- Развернуть AWX в Kubernetes
- Настроить доступ к веб-интерфейсу
- Создавать и запускать Ansible playbooks
- Управлять инвентарем серверов
- Автоматизировать развертывание приложений

Для получения дополнительной информации обратитесь к [официальной документации AWX](https://docs.ansible.com/ansible-tower/latest/html/administration/).