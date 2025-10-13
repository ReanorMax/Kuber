# Урок 2: Сети и мониторинг в Kubernetes

## Цель урока
Углубленно изучить сетевую модель Kubernetes и систему мониторинга на примере Prometheus стека.

## Теоретические основы

### 1. Сетевая модель Kubernetes

**Основные принципы:**
- Каждый Pod получает уникальный IP адрес
- Контейнеры внутри Pod общаются через localhost
- Pod'ы могут общаться друг с другом без NAT
- Service'ы предоставляют стабильную точку доступа к Pod'ам

**Компоненты сети:**
- **CNI (Container Network Interface)** - плагины для сетевой конфигурации
- **kube-proxy** - реализация Service'ов через iptables/IPVS
- **CoreDNS** - DNS сервер для service discovery

### 2. Service Discovery и DNS

В Kubernetes каждый Service получает DNS запись:
```
<service-name>.<namespace>.svc.cluster.local
```

Примеры из нашего кластера:
- `prometheus-grafana.monitoring.svc.cluster.local` 
- `prometheus-kube-prometheus-prometheus.monitoring.svc.cluster.local`

### 3. Ingress и внешний доступ

**Ingress Controller** - компонент который реализует Ingress правила:
- Маршрутизация HTTP/HTTPS трафика
- SSL/TLS терминация  
- Виртуальные хосты
- Path-based routing

## Практические упражнения

### Упражнение 1: Исследование сетевой конфигурации

```bash
# IP адреса всех Pod'ов
kubectl get pods -n monitoring -o wide

# Информация об узле
kubectl get nodes -o wide

# Сетевая конфигурация Pod'а
kubectl describe pod -n monitoring -l app.kubernetes.io/name=prometheus

# Проверка сетевых настроек внутри Pod'а
kubectl exec -n monitoring deployment/prometheus-grafana -- ip addr show
kubectl exec -n monitoring deployment/prometheus-grafana -- netstat -tlnp
```

**Задания:**
1. Какой диапазон IP используется для Pod'ов? (обычно 10.244.x.x в Minikube)
2. Какой IP у узла кластера?
3. На каких портах слушает Grafana внутри контейнера?

### Упражнение 2: Service Discovery и DNS

```bash
# Создайте debug Pod для тестирования сети
kubectl run netshoot --image=nicolaka/netshoot -i --tty --rm -- bash

# Внутри debug Pod'а выполните:
# Тестирование DNS резолвинга
nslookup prometheus-grafana.monitoring.svc.cluster.local
nslookup prometheus-kube-prometheus-prometheus.monitoring.svc.cluster.local

# Прямое подключение к сервисам
curl http://prometheus-grafana.monitoring.svc.cluster.local
curl http://prometheus-kube-prometheus-prometheus.monitoring.svc.cluster.local:9090/api/v1/status/config

# Проверка подключения к отдельным Pod'ам
curl http://<pod-ip>:3000  # IP Grafana Pod'а
curl http://<pod-ip>:9090  # IP Prometheus Pod'а
```

**Задания:**
1. Работает ли DNS резолвинг для всех сервисов?
2. Можете ли вы достучаться напрямую до Pod'ов по их IP?
3. В чем разница между подключением к Service и к Pod напрямую?

### Упражнение 3: Анализ Service'ов и Endpoints

```bash
# Подробная информация о Service'ах
kubectl get services -n monitoring -o wide
kubectl describe service prometheus-grafana -n monitoring

# Endpoints - Pod'ы стоящие за Service'ом
kubectl get endpoints -n monitoring
kubectl describe endpoints prometheus-grafana -n monitoring

# Проверка селекторов Service'а
kubectl get pods -n monitoring --show-labels | grep grafana
```

**Задания:**
1. Какие labels используются в селекторе Grafana Service'а?
2. Сколько Endpoints у каждого Service'а?
3. Что произойдет если Pod не будет соответствовать селектору Service'а?

### Упражнение 4: Ingress и внешний доступ

```bash
# Информация об Ingress правилах
kubectl get ingress -n monitoring
kubectl describe ingress grafana-ingress-ssl -n monitoring

# Статус Ingress Controller'а
kubectl get pods -n ingress-nginx
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller --tail=50

# Конфигурация nginx внутри Ingress Controller'а
kubectl exec -n ingress-nginx deployment/ingress-nginx-controller -- cat /etc/nginx/nginx.conf | grep -A 10 -B 5 "grafana.local"
```

**Задания:**
1. На какой Pod IP указывает Ingress для Grafana?
2. Какие SSL сертификаты используются?
3. Изучите nginx конфигурацию - как настроена маршрутизация для наших сервисов?

## Мониторинг и метрики

### Упражнение 5: Архитектура Prometheus

```bash
# Статус компонентов Prometheus стека
kubectl get all -n monitoring

# Конфигурация Prometheus
kubectl exec -n monitoring statefulset/prometheus-prometheus-kube-prometheus-prometheus -- cat /etc/prometheus/config_out/prometheus.env.yaml | head -50

# Targets которые мониторит Prometheus (через port-forward или Ingress)
# Откройте в браузере: https://prometheus.local/targets
```

**Изучите в Prometheus UI:**
1. **Status → Targets** - какие компоненты мониторятся
2. **Status → Configuration** - конфигурация scraping'а
3. **Status → Service Discovery** - автоматическое обнаружение целей

### Упражнение 6: Основы PromQL

Выполните запросы в Prometheus (https://prometheus.local):

```promql
# Базовые метрики
up                                          # Статус всех target'ов
node_memory_MemAvailable_bytes             # Доступная память узла
rate(container_cpu_usage_seconds_total[5m]) # CPU usage rate

# Метрики Kubernetes
kube_pod_info                              # Информация о Pod'ах
kube_deployment_status_replicas           # Количество реплик в Deployment'ах
kube_service_info                         # Информация о Service'ах

# Метрики приложений
prometheus_tsdb_head_samples_appended_total  # Количество добавленных семплов
grafana_http_request_duration_seconds       # Время ответа Grafana HTTP
```

**Задания:**
1. Сколько target'ов мониторит Prometheus?
2. Какое потребление CPU у Pod'а Grafana за последние 5 минут?
3. Сколько реплик у Deployment'а Grafana согласно метрикам?

### Упражнение 7: Создание дашборда в Grafana

1. **Откройте Grafana**: https://grafana.local (admin/admin123)

2. **Добавьте Prometheus как Data Source:**
   - Configuration → Data Sources → Add data source
   - Выберите Prometheus
   - URL: `http://prometheus-kube-prometheus-prometheus.monitoring.svc.cluster.local:9090`
   - Save & Test

3. **Создайте простой дашборд:**
   - Create → Dashboard → Add new panel
   - Добавьте метрики:
     ```promql
     # Panel 1: Статус сервисов
     up{job=~"kubernetes-.*"}
     
     # Panel 2: Потребление памяти Pod'ами
     sum(container_memory_working_set_bytes{container!=""}) by (pod)
     
     # Panel 3: HTTP запросы к Grafana
     rate(grafana_http_request_total[5m])
     ```

**Задания:**
1. Создайте дашборд с мониторингом ресурсов кластера
2. Добавьте алерты на высокое потребление CPU
3. Настройте автообновление дашборда каждые 30 секунд

## Практический проект: Мониторинг собственного приложения

### Упражнение 8: Инструментация приложения

Создадим приложение с метриками:

```yaml
# manifests/apps/app-with-metrics.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: metrics-app
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: metrics-app
  template:
    metadata:
      labels:
        app: metrics-app
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8080"
        prometheus.io/path: "/metrics"
    spec:
      containers:
      - name: app
        image: prom/node-exporter:latest
        ports:
        - containerPort: 9100
          name: metrics
        env:
        - name: NODE_ID
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
---
apiVersion: v1
kind: Service
metadata:
  name: metrics-app-service
  namespace: default
  labels:
    app: metrics-app
spec:
  selector:
    app: metrics-app
  ports:
  - port: 9100
    targetPort: 9100
    name: metrics
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: metrics-app-monitor
  namespace: default
  labels:
    app: metrics-app
spec:
  selector:
    matchLabels:
      app: metrics-app
  endpoints:
  - port: metrics
    interval: 30s
    path: /metrics
```

**Задания:**
1. Примените манифест и проверьте что приложение запустилось
2. Проверьте в Prometheus что новый target добавился в Service Discovery
3. Создайте дашборд в Grafana для мониторинга вашего приложения

### Упражнение 9: Сетевые политики (дополнительно)

```yaml
# manifests/security/network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: monitoring-network-policy
  namespace: monitoring
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/name: grafana
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    ports:
    - protocol: TCP
      port: 3000
  egress:
  - to:
    - podSelector:
        matchLabels:
          app.kubernetes.io/name: prometheus
    ports:
    - protocol: TCP
      port: 9090
```

## Диагностика и troubleshooting

### Упражнение 10: Отладка сетевых проблем

```bash
# Проверка connectivity между Pod'ами
kubectl exec -n monitoring deployment/prometheus-grafana -- wget -qO- http://prometheus-kube-prometheus-prometheus.monitoring.svc.cluster.local:9090/api/v1/status/config

# Проверка DNS резолвинга
kubectl exec -n monitoring deployment/prometheus-grafana -- nslookup prometheus-kube-prometheus-prometheus.monitoring.svc.cluster.local

# Анализ iptables правил (на узле)
sudo iptables -L -t nat | grep prometheus-grafana

# Логи kube-proxy
kubectl logs -n kube-system -l k8s-app=kube-proxy

# События кластера связанные с сетью
kubectl get events --field-selector reason=Failed --all-namespaces
```

## Домашнее задание

1. **Сетевое исследование:**
   - Создайте схему сетевого взаимодействия в вашем кластере
   - Проследите путь HTTP запроса от браузера до Pod'а Grafana
   - Определите все компоненты участвующие в маршрутизации

2. **Мониторинг производительности:**
   - Создайте дашборд для мониторинга производительности сети
   - Добавьте метрики: пропускная способность, задержка, потери пакетов
   - Настройте алерты на сетевые проблемы

3. **Service Discovery:**
   - Создайте дополнительное приложение в другом namespace
   - Настройте взаимодействие между приложениями через DNS
   - Проверьте изоляцию на уровне namespace'ов

4. **SSL/TLS исследование:**
   - Проанализируйте SSL сертификаты в Ingress
   - Создайте дополнительный домен для тестирования
   - Настройте SSL с Let's Encrypt (если возможно)

## Что изучили
- ✅ Сетевая модель Kubernetes и CNI
- ✅ Service Discovery и DNS в кластере
- ✅ Ingress и маршрутизация внешнего трафика
- ✅ Архитектура и принципы работы Prometheus
- ✅ Основы PromQL для запросов метрик
- ✅ Создание дашбордов в Grafana
- ✅ Инструментация приложений для мониторинга
- ✅ Диагностика сетевых проблем

## Следующий урок
В следующем уроке мы изучим:
- StatefulSets и Persistent Storage
- Резервное копирование и восстановление
- Высокая доступность и масштабирование
- Advanced networking (Network Policies, Mesh)
