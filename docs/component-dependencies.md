# Зависимости компонентов Kubernetes кластера

## Матрица зависимостей

| Компонент | Зависит от | Предоставляет для | Критичность |
|-----------|------------|------------------|-------------|
| **etcd** | - | API Server | Критический |
| **API Server** | etcd | Все компоненты | Критический |
| **Scheduler** | API Server | Pod scheduling | Критический |
| **Controller Manager** | API Server | Resource controllers | Критический |
| **kubelet** | API Server | Pod lifecycle | Критический |
| **kube-proxy** | API Server | Service networking | Критический |
| **CoreDNS** | API Server, kubelet | DNS resolution | Высокий |
| **Ingress Controller** | API Server, kube-proxy | External access | Высокий |
| **Prometheus** | API Server, kubelet, kube-state-metrics | Metrics storage | Средний |
| **Grafana** | Prometheus | Visualization | Низкий |
| **Alertmanager** | Prometheus | Alert routing | Средний |
| **Node Exporter** | kubelet | Node metrics | Низкий |

## Граф зависимостей

```
                         ┌─────────┐
                         │  etcd   │
                         └────┬────┘
                              │
                         ┌────▼────┐
                         │API Server│
                         └────┬────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
   ┌────▼────┐         ┌─────▼─────┐         ┌─────▼─────┐
   │Scheduler│         │Controller │         │  kubelet  │
   │         │         │ Manager   │         │           │
   └─────────┘         └───────────┘         └─────┬─────┘
                                                   │
                                            ┌─────▼─────┐
                                            │kube-proxy │
                                            └─────┬─────┘
                                                  │
   ┌──────────────────────────────────────────────┼──────────────────────────┐
   │                                              │                          │
┌──▼───┐  ┌──────────┐  ┌────────────┐  ┌────────▼────────┐  ┌─────────────┐
│CoreDNS│  │Prometheus│  │   Grafana  │  │Ingress Controller│  │Alertmanager │
└──────┘  └─────┬────┘  └─────┬──────┘  └─────────────────┘  └─────┬───────┘
                │             │                                     │
        ┌───────▼─────┐       │                                     │
        │kube-state   │       │        ┌────────────────────────────┘
        │  metrics    │       │        │
        └─────────────┘       │        │
                             │        │
        ┌─────────────┐       │        │
        │Node Exporter│       │        │
        └─────────────┘       │        │
                             │        │
                    ┌────────▼────────▼┐
                    │    Data Flow     │
                    │   Prometheus     │
                    │   ► Grafana      │
                    │   ► Alertmanager │
                    └──────────────────┘
```

## Порядок запуска компонентов

### Фаза 1: Core Infrastructure
1. **etcd** - хранилище данных кластера
2. **API Server** - центральная точка управления
3. **Controller Manager** - управление ресурсами
4. **Scheduler** - размещение подов

### Фаза 2: Node Components  
5. **kubelet** - агент узла
6. **kube-proxy** - сетевой прокси
7. **Container Runtime** - запуск контейнеров

### Фаза 3: Essential Services
8. **CoreDNS** - DNS резолвер кластера
9. **CNI Plugin** - сетевые интерфейсы (в Minikube встроен)

### Фаза 4: Infrastructure Services
10. **Ingress Controller** - внешний доступ
11. **Storage Classes** - управление хранилищем

### Фаза 5: Monitoring Stack
12. **Prometheus Operator** - управление Prometheus ресурсами
13. **Node Exporter** - метрики узла  
14. **kube-state-metrics** - метрики Kubernetes объектов
15. **Prometheus Server** - сбор и хранение метрик
16. **Alertmanager** - управление алертами
17. **Grafana** - визуализация

## Критические пути отказа

### Полный отказ кластера
```
etcd failure → API Server failure → Complete cluster failure
```

### Отказ мониторинга
```
API Server failure → Prometheus can't scrape → No metrics → Blind cluster
kubelet failure → Node metrics unavailable → Partial monitoring loss
```

### Отказ сетевых сервисов
```
kube-proxy failure → Service discovery broken → Internal communication issues
Ingress Controller failure → External access broken → External services unavailable
CoreDNS failure → DNS resolution broken → Service discovery issues
```

## Восстановление после отказов

### Порядок восстановления
1. Восстановить **etcd** (если применимо)
2. Перезапустить **API Server**
3. Дождаться восстановления **Controller Manager** и **Scheduler**
4. Проверить **kubelet** и **kube-proxy** на всех узлах
5. Восстановить **CoreDNS**
6. Восстановить **Ingress Controller**
7. Восстановить мониторинг по порядку: Operator → Prometheus → Grafana

### Команды для диагностики
```bash
# Проверка статуса системных компонентов
kubectl get componentstatuses

# Проверка системных подов
kubectl get pods -n kube-system

# Проверка событий кластера
kubectl get events --all-namespaces --sort-by='.lastTimestamp'

# Проверка логов критических компонентов
kubectl logs -n kube-system -l k8s-app=kube-dns
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller
```

## Метрики здоровья компонентов

### API Server
- **Metric**: `up{job="apiserver"}`
- **Health endpoint**: `https://192.168.49.2:8443/healthz`

### etcd
- **Metric**: `up{job="etcd"}`
- **Health check**: через API Server

### Prometheus
- **Metric**: `up{job="prometheus"}`
- **Health endpoint**: `http://prometheus:9090/-/healthy`

### Grafana
- **Metric**: `up{job="grafana"}`
- **Health endpoint**: `http://grafana:3000/api/health`

### Ingress Controller
- **Metric**: `nginx_ingress_controller_success`
- **Health endpoint**: встроенный в контроллер

## Влияние изменений

### Изменение конфигурации Prometheus
**Затрагивает**: Grafana (data source), Alertmanager (правила)
**Время восстановления**: ~30 секунд (перезагрузка конфигурации)

### Перезапуск Grafana
**Затрагивает**: только визуализация
**Время восстановления**: ~10 секунд

### Изменение Ingress правил
**Затрагивает**: внешний доступ к сервисам
**Время восстановления**: ~5-10 секунд (обновление nginx конфигурации)

### Перезапуск API Server
**Затрагивает**: весь кластер временно
**Время восстановления**: ~30-60 секунд
