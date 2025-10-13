# 📊 Prometheus Stack - Компоненты и их роли

## 🎯 **Обзор всех Pod'ов**

В Prometheus Stack **6 основных Pod'ов**, каждый выполняет свою роль:

```
┌─────────────────────────────────────────────────────────────────┐
│                    PROMETHEUS STACK                             │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │ Prometheus   │  │ Alertmanager │  │ Grafana              │  │
│  │ (Метрики)    │→ │ (Алерты)     │→ │ (Визуализация)       │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
│         ↑                                                       │
│         │ Собирает метрики                                     │
│         ↓                                                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │ Node Exporter│  │ Kube State   │  │ Operator             │  │
│  │ (Хост метрики│  │ Metrics      │  │ (Управление)         │  │
│  │              │  │ (K8s метрики)│  │                      │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📋 **Детальный разбор каждого Pod'а**

### **1. Prometheus Server** 🔍
**Pod**: `prometheus-prometheus-kube-prometheus-prometheus-0`

**Роль**: **ОСНОВНОЙ СЕРВЕР МЕТРИК**

**Что делает**:
- 📊 **Собирает метрики** со всех источников (scraping)
- 💾 **Хранит метрики** в time-series базе данных
- 🔎 **Выполняет запросы** PromQL
- 🚨 **Оценивает алерты** и отправляет в Alertmanager
- 🌐 **Предоставляет API** для Grafana и других инструментов

**Контейнеры** (2):
- `prometheus` - основной сервер Prometheus
- `config-reloader` - следит за изменениями конфигурации

**Доступ**:
- URL: http://10.19.1.209:9090
- UI: Graph, Alerts, Status, Configuration

**Метрики собирает от**:
- Kubernetes API (kubelet, API server, etc.)
- Node Exporter (метрики хоста)
- Kube State Metrics (объекты Kubernetes)
- Приложения с `/metrics` endpoint'ом

**Проверка**:
```bash
# Статус Pod'а
kubectl get pod prometheus-prometheus-kube-prometheus-prometheus-0 -n monitoring

# Логи
kubectl logs prometheus-prometheus-kube-prometheus-prometheus-0 -n monitoring -c prometheus --tail=20

# Targets (откуда собирает метрики)
curl http://10.19.1.209:9090/api/v1/targets | jq '.data.activeTargets[].labels.job'
```

---

### **2. Alertmanager** 🚨
**Pod**: `alertmanager-prometheus-kube-prometheus-alertmanager-0`

**Роль**: **УПРАВЛЕНИЕ АЛЕРТАМИ**

**Что делает**:
- 📬 **Получает алерты** от Prometheus
- 🔕 **Дедупликация** (убирает дубликаты)
- 🔔 **Группировка алертов** (объединяет связанные)
- ⏰ **Silencing** (временное отключение алертов)
- 📧 **Отправка уведомлений** (email, Slack, Telegram, etc.)
- 🔄 **Routing** (маршрутизация по правилам)

**Контейнеры** (2):
- `alertmanager` - основной сервис управления алертами
- `config-reloader` - следит за изменениями конфигурации

**Доступ**:
- URL: http://10.19.1.209:9093
- UI: Alerts, Silences, Status

**Примеры алертов**:
- `TargetDown` - сервис недоступен
- `HighMemoryUsage` - высокое использование памяти
- `PodCrashLooping` - Pod постоянно перезапускается

**Проверка**:
```bash
# Статус алертов
kubectl get pod alertmanager-prometheus-kube-prometheus-alertmanager-0 -n monitoring

# Логи
kubectl logs alertmanager-prometheus-kube-prometheus-alertmanager-0 -n monitoring -c alertmanager --tail=20

# Текущие алерты
curl http://10.19.1.209:9093/api/v2/alerts
```

---

### **3. Grafana** 📈
**Pod**: `prometheus-grafana-5746c56648-xkdlt`

**Роль**: **ВИЗУАЛИЗАЦИЯ ДАННЫХ**

**Что делает**:
- 📊 **Визуализация метрик** через дашборды
- 📉 **Графики** (линейные, bar charts, heatmaps)
- 🎨 **Кастомные дашборды** для разных целей
- 🔌 **Подключение к Prometheus** как источнику данных
- 👥 **Управление пользователями** и доступом
- 🔔 **Алертинг** (дополнительно к Alertmanager)

**Контейнеры** (3):
- `grafana` - основное приложение визуализации
- `grafana-sc-dashboard` - sidecar для автозагрузки дашбордов
- `grafana-sc-datasources` - sidecar для автозагрузки источников данных

**Доступ**:
- URL: http://10.19.1.209:3000
- Логин: admin / admin123

**Встроенные дашборды**:
- Kubernetes / Compute Resources / Cluster
- Kubernetes / Compute Resources / Namespace (Pods)
- Node Exporter / Nodes
- Prometheus / Overview

**Проверка**:
```bash
# Статус
kubectl get pod -n monitoring -l app.kubernetes.io/name=grafana

# Логи
kubectl logs deployment/prometheus-grafana -n monitoring -c grafana --tail=20

# Источники данных
curl -u admin:admin123 http://10.19.1.209:3000/api/datasources
```

---

### **4. Prometheus Operator** ⚙️
**Pod**: `prometheus-kube-prometheus-operator-d99cfb884-fghqb`

**Роль**: **УПРАВЛЕНИЕ PROMETHEUS В KUBERNETES**

**Что делает**:
- 🎛️ **Управляет жизненным циклом** Prometheus и Alertmanager
- 📝 **Создает конфигурацию** на основе CRD (Custom Resource Definitions)
- 🔄 **Автоматически обновляет** конфигурацию при изменениях
- 📦 **Управляет StatefulSet'ами** Prometheus/Alertmanager
- 🔍 **Следит за ServiceMonitor'ами** и создает scrape configs

**Контейнеры** (1):
- `kube-prometheus-stack-prometheus-operator` - оператор

**CRD которыми управляет**:
- `Prometheus` - конфигурация Prometheus сервера
- `Alertmanager` - конфигурация Alertmanager
- `ServiceMonitor` - автоматическое добавление scrape targets
- `PrometheusRule` - правила алертов
- `PodMonitor` - мониторинг Pod'ов напрямую

**Проверка**:
```bash
# Статус
kubectl get pod -n monitoring -l app=kube-prometheus-stack-operator

# Логи
kubectl logs deployment/prometheus-kube-prometheus-operator -n monitoring --tail=20

# Управляемые ресурсы
kubectl get prometheus,alertmanager,servicemonitor -n monitoring
```

---

### **5. Kube State Metrics** 📊
**Pod**: `prometheus-kube-state-metrics-57d78dcd7-65psd`

**Роль**: **МЕТРИКИ ОБЪЕКТОВ KUBERNETES**

**Что делает**:
- 🔍 **Слушает Kubernetes API** и преобразует состояние в метрики
- 📊 **Генерирует метрики** о Kubernetes объектах
- 📈 **Предоставляет /metrics** endpoint для Prometheus

**Метрики которые собирает**:
- **Deployments**: количество реплик, доступность
- **Pods**: статус, restarts, resource requests/limits
- **Nodes**: статус, capacity, allocatable
- **Services**: endpoints, статус
- **PersistentVolumes**: capacity, статус
- **ConfigMaps/Secrets**: количество

**Примеры метрик**:
```promql
# Количество Pod'ов в каждом namespace
kube_pod_info

# Pod'ы не в статусе Running
kube_pod_status_phase{phase!="Running"}

# Использование CPU по Pod'ам
kube_pod_container_resource_requests{resource="cpu"}
```

**Контейнеры** (1):
- `kube-state-metrics` - генератор метрик

**Проверка**:
```bash
# Статус
kubectl get pod -n monitoring -l app.kubernetes.io/name=kube-state-metrics

# Метрики
kubectl exec -n monitoring deployment/prometheus-kube-state-metrics -- wget -qO- localhost:8080/metrics | head -20
```

---

### **6. Node Exporter** 🖥️
**Pod**: `prometheus-prometheus-node-exporter-zw2vq`

**Роль**: **МЕТРИКИ ХОСТА (НОДЫ)**

**Что делает**:
- 💻 **Собирает метрики хоста** (CPU, память, диск, сеть)
- 📊 **Системные метрики** Linux
- 🔍 **Hardware метрики** (температура, voltage, etc.)
- 📈 **Предоставляет /metrics** endpoint

**Тип**: **DaemonSet** (запускается на каждой ноде)

**Метрики которые собирает**:
- **CPU**: usage, load average, context switches
- **Memory**: total, free, cached, swap
- **Disk**: usage, I/O, read/write
- **Network**: bytes in/out, packets, errors
- **Filesystem**: usage, inodes
- **System**: uptime, load, processes

**Примеры метрик**:
```promql
# CPU usage
node_cpu_seconds_total

# Memory available
node_memory_MemAvailable_bytes

# Disk usage
node_filesystem_avail_bytes

# Network traffic
node_network_receive_bytes_total
```

**Контейнеры** (1):
- `node-exporter` - экспортер метрик хоста

**Проверка**:
```bash
# Статус (DaemonSet - по одному на ноду)
kubectl get pod -n monitoring -l app.kubernetes.io/name=prometheus-node-exporter

# Метрики
kubectl exec -n monitoring daemonset/prometheus-prometheus-node-exporter -- wget -qO- localhost:9100/metrics | grep "node_cpu"
```

---

## 🔄 **Как они взаимодействуют?**

### **Поток данных**:

```
1. NODE EXPORTER
   └─→ Собирает метрики хоста (CPU, память)
       └─→ Предоставляет /metrics endpoint на порту 9100

2. KUBE STATE METRICS
   └─→ Слушает Kubernetes API
       └─→ Генерирует метрики о K8s объектах
           └─→ Предоставляет /metrics endpoint на порту 8080

3. PROMETHEUS SERVER
   └─→ Scraping (собирает) метрики:
       ├─→ Node Exporter (каждые 30s)
       ├─→ Kube State Metrics (каждые 30s)
       ├─→ Kubernetes API (kubelet, API server)
       └─→ Приложения с /metrics
   
   └─→ Сохраняет метрики в TSDB (Time Series Database)
   
   └─→ Оценивает alerting rules:
       └─→ Если условие алерта = true
           └─→ Отправляет в ALERTMANAGER

4. ALERTMANAGER
   └─→ Получает алерты от Prometheus
       └─→ Группирует и дедуплицирует
           └─→ Отправляет уведомления (email, Slack, etc.)

5. GRAFANA
   └─→ Запрашивает данные из Prometheus (PromQL)
       └─→ Визуализирует в дашбордах
           └─→ Показывает пользователю

6. PROMETHEUS OPERATOR
   └─→ Следит за CRD (ServiceMonitor, PrometheusRule)
       └─→ Автоматически обновляет конфигурацию Prometheus
           └─→ Перезагружает Prometheus при изменениях
```

---

## 📊 **Визуальная схема архитектуры**

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER                                    │
│                    (Браузер/Lens/kubectl)                       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ↓
                    ┌──────────────────┐
                    │     GRAFANA      │
                    │  Визуализация    │
                    │  :3000           │
                    └──────────────────┘
                              │
                              │ PromQL запросы
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    PROMETHEUS SERVER                            │
│                  (Сбор и хранение метрик)                       │
│                         :9090                                   │
└─────────────────────────────────────────────────────────────────┘
         │                    │                    │
         │ Scrape             │ Scrape             │ Alerts
         ↓                    ↓                    ↓
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│  NODE EXPORTER   │  │ KUBE STATE       │  │  ALERTMANAGER    │
│  (Метрики хоста) │  │ METRICS          │  │  (Управление     │
│  :9100           │  │ (K8s объекты)    │  │   алертами)      │
│                  │  │ :8080            │  │  :9093           │
└──────────────────┘  └──────────────────┘  └──────────────────┘
         ↑                    ↑
         │                    │
    ┌────────┐           ┌─────────────┐
    │  HOST  │           │ KUBERNETES  │
    │  (CPU, │           │    API      │
    │ Memory)│           │             │
    └────────┘           └─────────────┘

┌─────────────────────────────────────────────────────────────────┐
│              PROMETHEUS OPERATOR                                │
│         (Управление конфигурацией)                              │
│  Следит за: ServiceMonitor, PrometheusRule, Prometheus CRD      │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔍 **Как определить роль Pod'а?**

### **По имени Pod'а**:

```bash
# Получить все Pod'ы с описанием
kubectl get pods -n monitoring -o custom-columns=\
NAME:.metadata.name,\
COMPONENT:.metadata.labels.'app\.kubernetes\.io/name',\
IMAGE:.spec.containers[0].image

# Результат покажет компонент и образ
```

### **По label'ам**:

```bash
# Prometheus сервер
kubectl get pods -n monitoring -l app.kubernetes.io/name=prometheus

# Grafana
kubectl get pods -n monitoring -l app.kubernetes.io/name=grafana

# Alertmanager
kubectl get pods -n monitoring -l app.kubernetes.io/name=alertmanager
```

### **По портам**:

```bash
# Проверить порты каждого Pod'а
kubectl get pods -n monitoring -o json | jq -r '.items[] | "\(.metadata.name): \(.spec.containers[0].ports[0].containerPort)"'
```

**Результат**:
```
alertmanager-...: 9093          ← Alertmanager
prometheus-grafana-...: 3000    ← Grafana
prometheus-operator-...: 8080   ← Operator
kube-state-metrics-...: 8080    ← Kube State Metrics
prometheus-...: 9090            ← Prometheus Server
node-exporter-...: 9100         ← Node Exporter
```

---

## 📋 **Сводная таблица**

| Pod | Роль | Порт | Назначение | Тип |
|-----|------|------|------------|-----|
| **prometheus-prometheus-...** | 🔍 Сбор метрик | 9090 | Основной сервер метрик, хранение, PromQL | StatefulSet |
| **alertmanager-...** | 🚨 Алерты | 9093 | Управление и отправка алертов | StatefulSet |
| **prometheus-grafana-...** | 📈 Визуализация | 3000 | Дашборды и графики | Deployment |
| **prometheus-operator-...** | ⚙️ Управление | 8080 | Автоматизация конфигурации | Deployment |
| **kube-state-metrics-...** | 📊 K8s метрики | 8080 | Метрики объектов Kubernetes | Deployment |
| **node-exporter-...** | 🖥️ Хост метрики | 9100 | Метрики хоста (CPU, память) | DaemonSet |

---

## 🎯 **Практические команды**

### **Проверить статус всех компонентов**:

```bash
# Статус всех Pod'ов
kubectl get pods -n monitoring

# Сервисы (доступ)
kubectl get svc -n monitoring

# Endpoints (где Pod'ы слушают)
kubectl get endpoints -n monitoring
```

### **Логи каждого компонента**:

```bash
# Prometheus
kubectl logs prometheus-prometheus-kube-prometheus-prometheus-0 -n monitoring -c prometheus --tail=20

# Alertmanager
kubectl logs alertmanager-prometheus-kube-prometheus-alertmanager-0 -n monitoring -c alertmanager --tail=20

# Grafana
kubectl logs deployment/prometheus-grafana -n monitoring -c grafana --tail=20

# Operator
kubectl logs deployment/prometheus-kube-prometheus-operator -n monitoring --tail=20

# Kube State Metrics
kubectl logs deployment/prometheus-kube-state-metrics -n monitoring --tail=20

# Node Exporter
kubectl logs daemonset/prometheus-prometheus-node-exporter -n monitoring --tail=20
```

### **Доступ к UI каждого компонента**:

```bash
# Prometheus
curl http://10.19.1.209:9090

# Alertmanager
curl http://10.19.1.209:9093

# Grafana
curl http://10.19.1.209:3000

# Kube State Metrics (метрики)
kubectl port-forward -n monitoring deployment/prometheus-kube-state-metrics 8080:8080
curl http://localhost:8080/metrics

# Node Exporter (метрики)
kubectl port-forward -n monitoring daemonset/prometheus-prometheus-node-exporter 9100:9100
curl http://localhost:9100/metrics
```

---

## 🎓 **Резюме**

### **Основные компоненты**:

1. **Prometheus** - собирает и хранит метрики (ГЛАВНЫЙ)
2. **Alertmanager** - управляет алертами
3. **Grafana** - визуализация
4. **Operator** - автоматизация
5. **Kube State Metrics** - метрики K8s объектов
6. **Node Exporter** - метрики хоста

### **Поток данных**:
```
Node Exporter + Kube State → Prometheus → Grafana (визуализация)
                                    ↓
                              Alertmanager (уведомления)
```

### **Как определить роль**:
- По имени Pod'а (содержит название компонента)
- По label'ам (app.kubernetes.io/name)
- По портам (каждый компонент на своем порту)
- По описанию (kubectl describe pod)

**Теперь вы понимаете архитектуру Prometheus Stack!** 🚀

