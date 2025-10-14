# 🎯 AWX в Kubernetes - Деплой на внешние серверы

> 📚 **Навигация**: [← Назад к INDEX](INDEX.md) | [🏠 Главная](../README.md)

## 🤔 **Можно ли из AWX в Kubernetes деплоить на серверы?**

### **✅ ДА! Абсолютно можно!**

AWX в Kubernetes - это **всего лишь контейнер**, который запускает Ansible. Он может подключаться к **любым** серверам, к которым есть сетевой доступ:

```
┌─────────────────────────────────────────────────────────────┐
│              KUBERNETES CLUSTER                             │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                   AWX POD                            │  │
│  │  ┌────────────────────────────────────────────────┐ │  │
│  │  │  AWX Web UI (порт 8052)                        │ │  │
│  │  └────────────────────────────────────────────────┘ │  │
│  │  ┌────────────────────────────────────────────────┐ │  │
│  │  │  AWX Task (запускает Ansible)                  │ │  │
│  │  │  ├─→ SSH ключи                                │ │  │
│  │  │  ├─→ Ansible playbooks                        │ │  │
│  │  │  └─→ Inventory (список серверов)              │ │  │
│  │  └────────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────────┘  │
│                        │                                    │
└────────────────────────┼────────────────────────────────────┘
                         │
                         │ SSH (22), WinRM (5985/5986)
                         ↓
        ┌────────────────┴────────────────┐
        │                                 │
    ┌───▼───┐  ┌────────┐  ┌────────┐  ┌─▼──────┐
    │Server1│  │Server2 │  │Server3 │  │Windows │
    │Linux  │  │Linux   │  │Linux   │  │Server  │
    └───────┘  └────────┘  └────────┘  └────────┘
```

---

## 🎯 **Как это работает?**

### **Схема деплоя**:

1. **Вы** → Заходите в AWX Web UI (браузер)
2. **AWX** → Запускает Ansible playbook в Pod'е
3. **Ansible** → Подключается по SSH к вашим серверам
4. **Серверы** → Выполняют команды и конфигурируются

**Ключевой момент**: AWX в Kubernetes нужен только **сетевой доступ** к вашим серверам (SSH/WinRM).

---

## 🔧 **Установка AWX в Kubernetes**

### **Предварительные требования**:

```bash
# 1. Kubernetes кластер (у нас уже есть Kind)
kubectl get nodes
# ✅ Ready

# 2. Установить AWX Operator
kubectl apply -k https://github.com/ansible/awx-operator/config/default

# Проверить
kubectl get pods -n awx
```

---

### **Способ 1: Через AWX Operator** (рекомендуется) ⭐

#### **Шаг 1: Создать namespace**

```bash
kubectl create namespace awx
```

#### **Шаг 2: Установить AWX Operator**

```bash
# Скачать манифесты
git clone https://github.com/ansible/awx-operator.git
cd awx-operator

# Применить
kubectl apply -k config/default -n awx

# Проверить
kubectl get pods -n awx
```

#### **Шаг 3: Создать AWX Instance**

Создайте файл `awx-instance.yaml`:

```yaml
apiVersion: awx.ansible.com/v1beta1
kind: AWX
metadata:
  name: awx
  namespace: awx
spec:
  service_type: NodePort
  ingress_type: none
  hostname: awx.local
  
  # Persistent storage для данных
  projects_persistence: true
  projects_storage_size: 8Gi
  projects_storage_access_mode: ReadWriteOnce
  
  # PostgreSQL (база данных)
  postgres_configuration_secret: awx-postgres-configuration
  
  # Admin пароль
  admin_user: admin
  admin_password_secret: awx-admin-password
  
  # Ресурсы
  web_resource_requirements:
    requests:
      cpu: 500m
      memory: 1Gi
    limits:
      cpu: 1000m
      memory: 2Gi
  
  task_resource_requirements:
    requests:
      cpu: 500m
      memory: 1Gi
    limits:
      cpu: 1000m
      memory: 2Gi
```

#### **Шаг 4: Создать секреты**

```bash
# PostgreSQL секрет
kubectl create secret generic awx-postgres-configuration \
  --from-literal=host=awx-postgres \
  --from-literal=port=5432 \
  --from-literal=database=awx \
  --from-literal=username=awx \
  --from-literal=password=awxpass123 \
  --from-literal=type=managed \
  -n awx

# Admin пароль
kubectl create secret generic awx-admin-password \
  --from-literal=password=admin123 \
  -n awx
```

#### **Шаг 5: Применить манифест**

```bash
kubectl apply -f awx-instance.yaml

# Проверить статус
kubectl get awx -n awx

# Логи оператора
kubectl logs -f deployments/awx-operator-controller-manager -c awx-manager -n awx
```

#### **Шаг 6: Дождаться готовности (5-10 минут)**

```bash
# Проверить Pod'ы
kubectl get pods -n awx

# Должны быть:
# awx-postgres-xxx    1/1  Running
# awx-web-xxx         1/1  Running
# awx-task-xxx        1/1  Running
# awx-operator-xxx    2/2  Running
```

---

### **Способ 2: Через Helm** (быстрее)

```bash
# Добавить Helm repo
helm repo add awx-operator https://ansible.github.io/awx-operator/
helm repo update

# Установить AWX Operator
helm install awx-operator awx-operator/awx-operator -n awx --create-namespace

# Создать AWX instance
kubectl apply -f awx-instance.yaml -n awx
```

---

## 🌐 **Доступ к AWX**

### **Вариант 1: NodePort** (простой)

```bash
# Получить NodePort
kubectl get svc -n awx | grep awx-service

# Результат:
# awx-service   NodePort   10.96.x.x   <none>   80:30080/TCP

# Открыть в браузере:
http://10.19.1.209:30080
```

### **Вариант 2: Ingress** (для production)

Создайте файл `awx-ingress.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: awx-ingress
  namespace: awx
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  ingressClassName: nginx
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

```bash
kubectl apply -f awx-ingress.yaml

# Добавить в /etc/hosts
echo "10.19.1.209 awx.local" | sudo tee -a /etc/hosts

# Открыть
http://awx.local:8080
```

### **Вариант 3: Port-forward** (для тестирования)

```bash
kubectl port-forward -n awx svc/awx-service 8052:80 --address 0.0.0.0

# Открыть
http://10.19.1.209:8052
```

---

## 🔐 **Настройка AWX для деплоя на серверы**

### **Шаг 1: Логин в AWX**

```
URL: http://10.19.1.209:30080
Username: admin
Password: admin123 (или из секрета)
```

### **Шаг 2: Добавить SSH ключи**

AWX нужны SSH ключи для подключения к серверам:

#### **Создать SSH ключ** (если нет):

```bash
# Сгенерировать ключ
ssh-keygen -t rsa -b 4096 -f ~/.ssh/awx_key -N ""

# Скопировать публичный ключ на серверы
ssh-copy-id -i ~/.ssh/awx_key.pub root@192.168.1.10
ssh-copy-id -i ~/.ssh/awx_key.pub root@192.168.1.11
```

#### **Добавить в AWX**:

1. **AWX Web UI** → Resources → Credentials
2. **Add** → Credential Type: **Machine**
3. **Name**: `SSH Key for Servers`
4. **SSH Private Key**: (вставить содержимое `~/.ssh/awx_key`)
5. **Save**

---

### **Шаг 3: Создать Inventory (список серверов)**

1. **Resources** → **Inventories** → **Add** → **Inventory**
2. **Name**: `My Servers`
3. **Save**
4. **Hosts** → **Add Host**:
   - **Name**: `server1`
   - **Variables**:
     ```yaml
     ansible_host: 192.168.1.10
     ansible_user: root
     ansible_port: 22
     ```
5. Добавить еще серверы аналогично

---

### **Шаг 4: Создать Project (Git репозиторий с playbooks)**

1. **Resources** → **Projects** → **Add**
2. **Name**: `My Playbooks`
3. **SCM Type**: **Git**
4. **SCM URL**: `https://github.com/your-user/ansible-playbooks.git`
5. **Update on Launch**: ✅ (автоматически обновлять)
6. **Save**

**Или** использовать встроенный каталог:
- AWX автоматически создает `/var/lib/awx/projects/`
- Можно вручную загружать playbook'и туда

---

### **Шаг 5: Создать Job Template (шаблон задачи)**

1. **Resources** → **Templates** → **Add** → **Job Template**
2. **Name**: `Deploy Nginx`
3. **Inventory**: `My Servers` (выбрать созданный)
4. **Project**: `My Playbooks`
5. **Playbook**: `deploy-nginx.yml` (выбрать из проекта)
6. **Credentials**: `SSH Key for Servers`
7. **Save**

---

### **Шаг 6: Запустить деплой!** 🚀

1. **Templates** → **Deploy Nginx** → **Launch** (кнопка ракеты 🚀)
2. AWX запустит Ansible playbook
3. **Output** покажет логи выполнения в реальном времени
4. ✅ Серверы сконфигурируются!

---

## 📝 **Пример Ansible Playbook**

Создайте `deploy-nginx.yml`:

```yaml
---
- name: Deploy Nginx on servers
  hosts: all
  become: yes
  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes
      when: ansible_os_family == "Debian"
    
    - name: Install Nginx
      package:
        name: nginx
        state: present
    
    - name: Start Nginx
      service:
        name: nginx
        state: started
        enabled: yes
    
    - name: Deploy custom index.html
      copy:
        content: |
          <html>
          <body>
            <h1>Deployed from AWX in Kubernetes!</h1>
            <p>Server: {{ inventory_hostname }}</p>
            <p>IP: {{ ansible_default_ipv4.address }}</p>
          </body>
          </html>
        dest: /var/www/html/index.html
        owner: www-data
        group: www-data
        mode: '0644'
    
    - name: Verify Nginx is running
      uri:
        url: http://localhost
        return_content: yes
      register: nginx_check
    
    - name: Show result
      debug:
        msg: "Nginx is running on {{ inventory_hostname }}"
```

---

## 🔄 **Как AWX деплоит из Kubernetes на внешние серверы?**

### **Детальная схема**:

```
1. ВЫ → AWX Web UI
   └─→ Нажимаете "Launch" на Job Template

2. AWX Web (Pod в K8s)
   └─→ Создает Job в базе данных PostgreSQL
   └─→ Отправляет задачу в очередь (RabbitMQ/Redis)

3. AWX Task (Pod в K8s)
   └─→ Получает задачу из очереди
   └─→ Создает временный контейнер для выполнения
   └─→ Загружает:
       ├─→ Playbook из Git
       ├─→ Inventory (список серверов)
       ├─→ SSH ключи из Kubernetes Secret
       └─→ Переменные окружения

4. ANSIBLE (внутри AWX Task Pod)
   └─→ Читает playbook и inventory
   └─→ Подключается по SSH к серверам:
       ├─→ server1: 192.168.1.10:22
       ├─→ server2: 192.168.1.11:22
       └─→ server3: 192.168.1.12:22
   
5. СЕРВЕРЫ
   └─→ Принимают SSH подключения
   └─→ Выполняют команды Ansible
   └─→ Возвращают результаты

6. AWX Task
   └─→ Собирает логи выполнения
   └─→ Сохраняет результаты в PostgreSQL

7. AWX Web UI
   └─→ Показывает логи в реальном времени
   └─→ ✅ Job completed!
```

---

## 🌐 **Сетевые требования**

### **AWX Pod в Kubernetes должен иметь доступ к**:

1. **SSH порт 22** на целевых серверах
   - Linux: SSH
   - Windows: OpenSSH или WinRM (5985/5986)

2. **Интернет** (опционально):
   - Для загрузки playbook'ов из Git
   - Для установки пакетов на серверах

3. **Kubernetes API** (уже есть):
   - Для хранения секретов
   - Для управления Pod'ами

### **Проверка доступности**:

```bash
# Из Pod'а AWX к серверу
kubectl exec -it -n awx deployment/awx-task -- ssh -i /path/to/key root@192.168.1.10 echo "OK"

# Или через временный Pod
kubectl run -it --rm debug --image=alpine --restart=Never -- sh
apk add openssh-client
ssh root@192.168.1.10
```

---

## 🔐 **Безопасность**

### **1. SSH ключи в Kubernetes Secrets**:

```bash
# Создать Secret с SSH ключом
kubectl create secret generic awx-ssh-key \
  --from-file=ssh-privatekey=/root/.ssh/awx_key \
  -n awx

# AWX автоматически использует этот Secret
```

### **2. RBAC для AWX**:

```yaml
# AWX Service Account с ограниченными правами
apiVersion: v1
kind: ServiceAccount
metadata:
  name: awx-service-account
  namespace: awx
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: awx-role
  namespace: awx
rules:
- apiGroups: [""]
  resources: ["secrets", "configmaps"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: awx-role-binding
  namespace: awx
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: awx-role
subjects:
- kind: ServiceAccount
  name: awx-service-account
  namespace: awx
```

### **3. Network Policies** (опционально):

```yaml
# Разрешить AWX только SSH (22) к серверам
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: awx-egress
  namespace: awx
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/component: awx
  policyTypes:
  - Egress
  egress:
  - to:
    - ipBlock:
        cidr: 192.168.1.0/24  # Ваша сеть серверов
    ports:
    - protocol: TCP
      port: 22
```

---

## 📊 **Мониторинг AWX**

### **Prometheus метрики**:

AWX предоставляет метрики на `/metrics`:

```yaml
# ServiceMonitor для Prometheus
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: awx
  namespace: awx
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: awx
  endpoints:
  - port: http
    path: /metrics
```

### **Grafana Dashboard**:

Можно импортировать готовый дашборд для AWX или создать свой с метриками:
- Количество запущенных Jobs
- Успешные/неудачные выполнения
- Время выполнения playbook'ов

---

## 🎯 **Практический пример: Деплой на 3 сервера**

### **Сценарий**: Установить Nginx + Prometheus Node Exporter на 3 сервера

#### **1. Inventory в AWX**:

```yaml
all:
  hosts:
    web1:
      ansible_host: 192.168.1.10
    web2:
      ansible_host: 192.168.1.11
    web3:
      ansible_host: 192.168.1.12
  vars:
    ansible_user: root
    ansible_ssh_private_key_file: /runner/secrets/ssh_key
```

#### **2. Playbook**:

```yaml
---
- name: Setup web servers
  hosts: all
  become: yes
  tasks:
    - name: Install packages
      apt:
        name:
          - nginx
          - prometheus-node-exporter
        state: present
        update_cache: yes
    
    - name: Configure Nginx
      template:
        src: nginx.conf.j2
        dest: /etc/nginx/sites-available/default
      notify: restart nginx
    
    - name: Start services
      service:
        name: "{{ item }}"
        state: started
        enabled: yes
      loop:
        - nginx
        - prometheus-node-exporter
  
  handlers:
    - name: restart nginx
      service:
        name: nginx
        state: restarted
```

#### **3. Запуск из AWX**:

1. Create Job Template
2. Launch
3. ✅ Все 3 сервера сконфигурированы за 2 минуты!

---

## 🔗 **Интеграция с Prometheus**

После развертывания серверы можно сразу добавить в Prometheus:

```yaml
# ServiceMonitor для новых серверов
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: external-servers
  namespace: monitoring
spec:
  endpoints:
  - port: node-exporter
    interval: 30s
    path: /metrics
    targetPort: 9100
    staticConfig:
      static_configs:
      - targets:
        - 192.168.1.10:9100
        - 192.168.1.11:9100
        - 192.168.1.12:9100
```

---

## ✅ **Преимущества AWX в Kubernetes**

1. **Масштабируемость**: Легко добавить больше AWX task workers
2. **Отказоустойчивость**: Kubernetes перезапустит упавший Pod
3. **Централизация**: Все playbook'и в Git, все ключи в Secrets
4. **Мониторинг**: Интеграция с Prometheus/Grafana
5. **Безопасность**: RBAC, Network Policies, Secret encryption

---

## ❌ **Ограничения и нюансы**

### **1. Сетевой доступ**:
- ⚠️ AWX Pod должен "видеть" ваши серверы
- Если серверы за NAT - нужен VPN или reverse SSH tunnel

### **2. Performance**:
- ⚠️ AWX в Kind (на одной ноде) - только для тестов
- Production: используйте многонодовый кластер (EKS, GKE, AKS)

### **3. Persistent Storage**:
- ⚠️ Projects и logs нужно хранить на PersistentVolume
- В Kind: можно использовать local-path-provisioner

---

## 🎓 **Резюме**

### **✅ Можно ли деплоить на серверы из AWX в Kubernetes?**

**ДА! Абсолютно можно и это стандартная практика!**

**Как это работает**:
1. AWX работает в Pod'е Kubernetes
2. Ansible запускается внутри Pod'а
3. Ansible подключается по SSH к вашим серверам
4. Серверы могут быть где угодно (лишь бы был SSH доступ)

**Что нужно**:
- ✅ Kubernetes кластер (у нас Kind)
- ✅ AWX Operator
- ✅ SSH ключи для серверов
- ✅ Сетевой доступ от Pod'а к серверам
- ✅ Ansible playbook'и (в Git или локально)

**Преимущества**:
- 🎯 Централизованное управление
- 📊 Веб UI для запуска playbook'ов
- 🔐 Безопасное хранение ключей в Kubernetes Secrets
- 📈 Мониторинг через Prometheus
- ♻️ Переиспользование playbook'ов

---

## 🔗 **Связанные документы**

### **Kubernetes концепции**:
- [📦 ConfigMaps](configmaps-explained.md) - как хранить конфигурацию
- [📊 Prometheus Stack](prometheus-stack-components.md) - мониторинг AWX
- [🔐 Secrets в Kubernetes](learning-guide-01-basics.md) - хранение SSH ключей

### **Сеть**:
- [🌐 Проброс портов](port-forwarding-explained.md) - доступ к AWX UI
- [📖 Урок 2: Сети](learning-guide-02-networking-monitoring.md) - как AWX подключается к серверам

### **Навигация**:
- [📚 Полный индекс документации](INDEX.md)
- [🏠 Главная страница](../README.md)

---

**Теперь вы знаете как развернуть AWX в Kubernetes и деплоить на внешние серверы!** 🚀

*AWX + Kubernetes = мощная комбинация для автоматизации инфраструктуры!*

