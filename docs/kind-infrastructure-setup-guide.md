# Полное руководство по установке Kind инфраструктуры

## Обзор

Это пошаговое руководство описывает весь процесс создания Kubernetes кластера на базе Kind с полным мониторинг стеком и внешним доступом.

## Предварительные требования

### Системные требования
- **ОС**: Linux (Ubuntu/Debian/CentOS/RHEL)
- **RAM**: Минимум 2GB, рекомендуется 4GB+
- **CPU**: Минимум 2 ядра
- **Диск**: Минимум 10GB свободного места
- **Сеть**: Доступ в интернет для загрузки образов

### Необходимый софт
- Docker
- kubectl
- Helm
- curl/wget

## Шаг 1: Подготовка системы

### Установка Docker (если не установлен)

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER

# CentOS/RHEL
sudo yum install -y docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER

# Перелогинься или выполни:
newgrp docker

# Проверка установки
docker --version
docker ps
```

### Установка kubectl

```bash
# Загрузка последней стабильной версии
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Делаем исполняемым и устанавливаем
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Проверяем установку
kubectl version --client
```

### Установка Helm

```bash
# Скачиваем и устанавливаем Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Проверяем установку
helm version
```

## Шаг 2: Установка Kind

### Загрузка и установка Kind

```bash
# Загружаем Kind для Linux AMD64
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64

# Делаем исполняемым и устанавливаем
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Проверяем установку
kind version
```

### Создание конфигурационного файла

```bash
# Создаем рабочую директорию
mkdir -p kubernetes-learning
cd kubernetes-learning

# Создаем конфигурацию Kind с внешним доступом
cat << EOF > kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: learning-cluster

# Настройка сети для простого доступа
networking:
  podSubnet: "10.244.0.0/16"
  serviceSubnet: "10.96.0.0/12"

nodes:
- role: control-plane
  # Проброс портов для прямого доступа к сервисам
  extraPortMappings:
  - containerPort: 30080  # Grafana
    hostPort: 3000
    protocol: TCP
  - containerPort: 30090  # Prometheus  
    hostPort: 9090
    protocol: TCP
  - containerPort: 30093  # Alertmanager
    hostPort: 9093
    protocol: TCP
  - containerPort: 80     # Ingress HTTP
    hostPort: 8080
    protocol: TCP
  - containerPort: 443    # Ingress HTTPS
    hostPort: 8443
    protocol: TCP

# Дополнительные фичи для обучения
featureGates:
  "EphemeralContainers": true
  "LocalStorageCapacityIsolation": true
EOF
```

## Шаг 3: Создание Kind кластера

### Запуск кластера

```bash
# Создаем кластер с нашей конфигурацией
kind create cluster --config=kind-config.yaml --name=learning-cluster

# Проверяем что кластер создался
kubectl cluster-info --context kind-learning-cluster
```

### Проверка состояния кластера

```bash
# Проверяем узлы
kubectl get nodes

# Проверяем системные поды
kubectl get pods -n kube-system

# Проверяем что контекст переключился на Kind
kubectl config current-context
```

**Ожидаемый результат:**
```
NAME                             STATUS   ROLES           AGE   VERSION
learning-cluster-control-plane   Ready    control-plane   2m    v1.27.3
```

## Шаг 4: Установка Ingress Controller

### Установка Nginx Ingress для Kind

```bash
# Применяем манифест Ingress Controller оптимизированный для Kind
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```

### Ожидание готовности Ingress Controller

```bash
# Ждем пока Ingress Controller станет готов
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

# Проверяем статус
kubectl get pods -n ingress-nginx
```

**Ожидаемый результат:**
```
NAME                                        READY   STATUS      RESTARTS   AGE
ingress-nginx-controller-xxxx               1/1     Running     0          2m
ingress-nginx-admission-create-xxxx         0/1     Completed   0          2m
ingress-nginx-admission-patch-xxxx          0/1     Completed   0          2m
```

## Шаг 5: Установка мониторинг стека

### Добавление Helm репозиториев

```bash
# Добавляем репозиторий Prometheus Community
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Обновляем индексы репозиториев
helm repo update

# Проверяем что репозиторий добавился
helm repo list
```

### Установка kube-prometheus-stack

```bash
# Устанавливаем полный мониторинг стек с правильными настройками
helm install prometheus prometheus-community/kube-prometheus-stack \
    --namespace monitoring \
    --create-namespace \
    --set grafana.adminPassword=admin123 \
    --set grafana.service.type=NodePort \
    --set grafana.service.nodePort=30080 \
    --set prometheus.service.type=NodePort \
    --set prometheus.service.nodePort=30090 \
    --set alertmanager.service.type=NodePort \
    --set alertmanager.service.nodePort=30093 \
    --wait --timeout=10m
```

**Важные параметры:**
- `grafana.service.type=NodePort` - делает Grafana доступной снаружи
- `grafana.service.nodePort=30080` - фиксирует порт 30080 для Grafana
- `--wait --timeout=10m` - ждет полной готовности всех компонентов

### Проверка установки мониторинга

```bash
# Проверяем поды в namespace monitoring
kubectl get pods -n monitoring

# Проверяем сервисы с NodePort
kubectl get svc -n monitoring | grep NodePort

# Проверяем что все поды запустились
kubectl wait --namespace monitoring \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=grafana \
  --timeout=300s
```

**Ожидаемый результат:**
```
NAME                                                     READY   STATUS    RESTARTS   AGE
alertmanager-prometheus-kube-prometheus-alertmanager-0   2/2     Running   0          5m
prometheus-grafana-xxxxxx                                3/3     Running   0          5m
prometheus-kube-prometheus-operator-xxxxxx               1/1     Running   0          5m
prometheus-kube-state-metrics-xxxxxx                     1/1     Running   0          5m
prometheus-prometheus-kube-prometheus-prometheus-0       2/2     Running   0          5m
prometheus-prometheus-node-exporter-xxxxxx               1/1     Running   0          5m
```

## Шаг 6: Проверка доступности сервисов

### Определение внешнего IP

```bash
# Получаем внешний IP сервера
EXTERNAL_IP=$(hostname -I | awk '{print $1}')
echo "Внешний IP сервера: $EXTERNAL_IP"

# Или используем другие методы если нужно
# EXTERNAL_IP=$(curl -s ifconfig.me)  # Публичный IP
# EXTERNAL_IP="localhost"  # Для локального доступа
```

### Проверка доступности через curl

```bash
# Проверяем Grafana
curl -I http://$EXTERNAL_IP:3000
curl -I http://localhost:3000

# Проверяем Prometheus  
curl -I http://$EXTERNAL_IP:9090
curl -I http://localhost:9090

# Проверяем Alertmanager
curl -I http://$EXTERNAL_IP:9093
curl -I http://localhost:9093
```

### Получение информации о доступе

```bash
echo "🎯 Доступ к сервисам:"
echo "  📊 Grafana:      http://$EXTERNAL_IP:3000 (admin/admin123)"
echo "  📈 Prometheus:   http://$EXTERNAL_IP:9090"
echo "  🚨 Alertmanager: http://$EXTERNAL_IP:9093"
```

## Шаг 7: Создание дополнительных ресурсов

### Создание примеров приложений

```bash
# Создаем директории для манифестов
mkdir -p manifests/{apps,monitoring,ingress}

# Создаем простое демо приложение
cat << 'EOF' > manifests/apps/hello-kubernetes.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-kubernetes
  namespace: default
spec:
  replicas: 3
  selector:
    matchLabels:
      app: hello-kubernetes
  template:
    metadata:
      labels:
        app: hello-kubernetes
    spec:
      containers:
      - name: hello-kubernetes
        image: k8s.gcr.io/echoserver:1.4
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: hello-kubernetes-service
  namespace: default
spec:
  selector:
    app: hello-kubernetes
  ports:
  - port: 80
    targetPort: 8080
  type: ClusterIP
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: hello-kubernetes-ingress
  namespace: default
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: hello.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: hello-kubernetes-service
            port:
              number: 80
EOF

# Применяем демо приложение
kubectl apply -f manifests/apps/hello-kubernetes.yaml
```

### Создание скриптов управления

```bash
# Создаем скрипт для быстрого статуса
cat << 'EOF' > scripts/kind-status.sh
#!/bin/bash
echo "🔍 Kind Cluster Status"
echo "====================="

echo "📊 Cluster Info:"
kubectl cluster-info --context kind-learning-cluster

echo -e "\n🖥️ Nodes:"
kubectl get nodes

echo -e "\n📦 Monitoring Pods:"
kubectl get pods -n monitoring

echo -e "\n🌐 Services:"
kubectl get svc -n monitoring | grep NodePort

EXTERNAL_IP=$(hostname -I | awk '{print $1}')
echo -e "\n🎯 Access URLs:"
echo "  📊 Grafana:      http://$EXTERNAL_IP:3000"
echo "  📈 Prometheus:   http://$EXTERNAL_IP:9090" 
echo "  🚨 Alertmanager: http://$EXTERNAL_IP:9093"
EOF

chmod +x scripts/kind-status.sh
```

## Шаг 8: Backup и восстановление

### Создание backup скрипта

```bash
cat << 'EOF' > scripts/kind-backup.sh
#!/bin/bash
# Backup Kind кластера

BACKUP_DIR="backup/kind-cluster-$(date +%Y%m%d_%H%M%S)"
mkdir -p $BACKUP_DIR

echo "💾 Создание backup кластера..."

# Backup Helm releases
helm list -A > $BACKUP_DIR/helm-releases.txt

# Backup Helm values
helm get values prometheus -n monitoring > $BACKUP_DIR/prometheus-values.yaml

# Backup важных манифестов
kubectl get all -A -o yaml > $BACKUP_DIR/all-resources.yaml
kubectl get ingress -A -o yaml > $BACKUP_DIR/ingress.yaml
kubectl get pvc -A -o yaml > $BACKUP_DIR/pvc.yaml

# Backup Kind config
cp kind-config.yaml $BACKUP_DIR/

echo "✅ Backup сохранен в: $BACKUP_DIR"
EOF

chmod +x scripts/kind-backup.sh
```

### Создание скрипта восстановления

```bash
cat << 'EOF' > scripts/kind-restore.sh
#!/bin/bash
# Восстановление Kind кластера

BACKUP_DIR=${1:-"backup/latest"}

if [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ Backup директория не найдена: $BACKUP_DIR"
    exit 1
fi

echo "🔄 Восстановление из backup: $BACKUP_DIR"

# Пересоздаем кластер
kind delete cluster --name=learning-cluster
kind create cluster --config=$BACKUP_DIR/kind-config.yaml --name=learning-cluster

# Устанавливаем Ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Ждем готовности
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=90s

# Восстанавливаем Helm
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Восстанавливаем мониторинг
helm install prometheus prometheus-community/kube-prometheus-stack \
    --namespace monitoring \
    --create-namespace \
    --values $BACKUP_DIR/prometheus-values.yaml \
    --wait --timeout=10m

echo "✅ Восстановление завершено"
EOF

chmod +x scripts/kind-restore.sh
```

## Troubleshooting

### Частые проблемы и решения

#### 1. Kind кластер не создается

**Проблема**: `ERROR: failed to create cluster`

**Решения**:
```bash
# Проверяем Docker
docker ps

# Освобождаем порты если заняты
sudo lsof -i :3000
sudo lsof -i :9090
sudo kill <PID>

# Удаляем старые кластеры
kind delete cluster --name=learning-cluster

# Очищаем Docker сети
docker network prune
```

#### 2. Поды мониторинга не запускаются

**Проблема**: Поды в состоянии `Pending` или `CrashLoopBackOff`

**Решения**:
```bash
# Проверяем ресурсы
kubectl describe nodes
kubectl top nodes

# Проверяем события
kubectl get events -n monitoring --sort-by='.lastTimestamp'

# Проверяем логи подов
kubectl logs -n monitoring deployment/prometheus-grafana
```

#### 3. Нет доступа к сервисам снаружи

**Проблема**: Сервисы недоступны по внешнему IP

**Решения**:
```bash
# Проверяем что порты пробросились
docker ps | grep learning-cluster

# Проверяем NodePort сервисы
kubectl get svc -n monitoring

# Проверяем файрвол
sudo ufw status
sudo iptables -L | grep 3000
```

#### 4. Grafana не загружается

**Проблема**: Grafana доступна но не загружается

**Решения**:
```bash
# Перезапускаем Grafana
kubectl rollout restart deployment/prometheus-grafana -n monitoring

# Проверяем логи
kubectl logs -n monitoring deployment/prometheus-grafana -c grafana

# Проверяем конфигурацию
kubectl describe deployment prometheus-grafana -n monitoring
```

## Мониторинг и обслуживание

### Ежедневные проверки

```bash
# Создаем скрипт ежедневной проверки
cat << 'EOF' > scripts/daily-check.sh
#!/bin/bash
echo "📅 Ежедневная проверка Kind кластера - $(date)"
echo "================================================="

# Проверяем статус кластера
kubectl get nodes
kubectl get pods -n monitoring --no-headers | awk '{print $1, $3}' | grep -v Running && echo "⚠️ Есть не работающие поды" || echo "✅ Все поды работают"

# Проверяем доступность сервисов
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 | grep -q 200 && echo "✅ Grafana доступна" || echo "❌ Grafana недоступна"
curl -s -o /dev/null -w "%{http_code}" http://localhost:9090 | grep -q 200 && echo "✅ Prometheus доступен" || echo "❌ Prometheus недоступен"

# Проверяем использование ресурсов
kubectl top nodes 2>/dev/null && echo "✅ Metrics доступны" || echo "⚠️ Metrics недоступны"

echo "================================================="
EOF

chmod +x scripts/daily-check.sh
```

### Обновление компонентов

```bash
# Обновление Helm charts
helm repo update

# Проверка доступных обновлений
helm list -n monitoring
helm search repo prometheus-community/kube-prometheus-stack

# Обновление мониторинг стека
helm upgrade prometheus prometheus-community/kube-prometheus-stack \
    --namespace monitoring \
    --reuse-values
```

## Заключение

После выполнения всех шагов у вас будет:

✅ **Функциональный Kubernetes кластер на Kind**
✅ **Полный мониторинг стек (Prometheus + Grafana + Alertmanager)**
✅ **Прямой внешний доступ без port-forward**
✅ **Ingress Controller для веб-приложений**
✅ **Скрипты управления и обслуживания**
✅ **Система backup и восстановления**

### Следующие шаги для изучения

1. **Изучите готовые дашборды в Grafana**
2. **Создавайте собственные приложения**  
3. **Экспериментируйте с PromQL запросами**
4. **Настраивайте алерты в Alertmanager**
5. **Изучайте Kubernetes объекты на практике**

### Полезные команды для работы

```bash
# Управление кластером
kind get clusters
kubectl config get-contexts
kubectl config use-context kind-learning-cluster

# Мониторинг
./scripts/kind-status.sh
./scripts/daily-check.sh

# Backup и восстановление
./scripts/kind-backup.sh
./scripts/kind-restore.sh backup/kind-cluster-20231013_120000
```

**🎉 Поздравляем! У вас теперь есть полноценная среда для изучения Kubernetes!**
