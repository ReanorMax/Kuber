# Текущая архитектура Kubernetes кластера

## Обзор кластера

**Тип кластера**: Minikube (single-node)
**Версия Kubernetes**: v1.34.0  
**Операционная система**: Ubuntu 22.04.5 LTS
**Container Runtime**: Docker 28.4.0
**Внутренний IP узла**: 192.168.49.2

## Компоненты Control Plane

### API Server
- **Адрес**: https://192.168.49.2:8443
- **Функции**: Центральная точка управления кластером, обрабатывает REST API запросы
- **Состояние**: Активный

### etcd
- **Функции**: Распределенное key-value хранилище для всех данных кластера
- **Состояние**: Встроен в Minikube

### Scheduler
- **Функции**: Назначает поды на узлы на основе требований ресурсов
- **Состояние**: Активный

### Controller Manager
- **Функции**: Запускает контроллеры для управления репликацией, endpoints, etc.
- **Состояние**: Активный

## Node компоненты

### kubelet
- **Функции**: Агент на каждом узле, управляет подами и контейнерами
- **Состояние**: Активный на minikube узле

### kube-proxy
- **Функции**: Сетевой прокси, управляет правилами iptables для Services
- **Состояние**: Активный

### Container Runtime (Docker)
- **Версия**: 28.4.0
- **Функции**: Запускает контейнеры

## Namespaces и их назначение

### default
- **Назначение**: Пространство имен по умолчанию для пользовательских приложений
- **Состояние**: Активно, пустое

### kube-system
- **Назначение**: Системные компоненты Kubernetes
- **Основные компоненты**:
  - CoreDNS (DNS резолвер кластера)
  - kube-proxy DaemonSet
  - Системные поды etcd, api-server, controller-manager, scheduler

### kube-public
- **Назначение**: Публично доступная информация о кластере
- **Состояние**: Активно

### kube-node-lease
- **Назначение**: Lease объекты для heartbeat узлов
- **Состояние**: Активно

### monitoring
- **Назначение**: Мониторинг и наблюдаемость
- **Основные компоненты**:
  - Prometheus Operator
  - Prometheus Server (StatefulSet)
  - Grafana (Deployment)
  - Alertmanager (StatefulSet) 
  - Node Exporter (DaemonSet)
  - kube-state-metrics (Deployment)

### ingress-nginx
- **Назначение**: Ingress контроллер для управления внешним доступом
- **Основные компоненты**:
  - nginx-ingress-controller (Deployment)
  - Admission контроллеры (Jobs)

## Мониторинг стек (kube-prometheus-stack)

### Prometheus Server
- **Тип**: StatefulSet
- **Реплики**: 1
- **Порты**: 9090 (HTTP API), 8080 (reload)
- **Persistent Storage**: Да (для метрик)
- **Service**: ClusterIP (10.109.71.185:9090)

### Grafana
- **Тип**: Deployment  
- **Реплики**: 1
- **Порты**: 3000 (HTTP)
- **Service**: NodePort (10.101.69.9:80 -> :31282)
- **Ingress**: Настроен (grafana.local)
- **Административный доступ**: admin/admin123

### Alertmanager
- **Тип**: StatefulSet
- **Реплики**: 1
- **Порты**: 9093, 8080
- **Service**: ClusterIP (10.102.82.194:9093)

### Node Exporter
- **Тип**: DaemonSet (на каждом узле)
- **Порты**: 9100
- **Функция**: Сбор метрик узла

### kube-state-metrics
- **Тип**: Deployment
- **Порты**: 8080
- **Функция**: Экспорт метрик состояния Kubernetes объектов

## Сетевая архитектура

### Services типы и их использование

#### ClusterIP Services
- `prometheus-kube-prometheus-prometheus` - внутренний доступ к Prometheus
- `prometheus-grafana` - базовый ClusterIP для Grafana (переопределен на NodePort)
- `prometheus-kube-prometheus-alertmanager` - внутренний доступ к Alertmanager
- Все остальные системные сервисы

#### NodePort Services  
- `prometheus-grafana` - внешний доступ к Grafana через порт 31282
- `ingress-nginx-controller` - внешний доступ к Ingress (30258:80, 32605:443)

#### Headless Services
- `prometheus-operated` - для StatefulSet Prometheus
- `alertmanager-operated` - для StatefulSet Alertmanager

### Ingress конфигурация

#### Текущие Ingress правила
```yaml
# grafana-ingress (monitoring namespace)
Host: grafana.local
Path: / -> prometheus-grafana:80 (pod IP: 10.244.0.13:3000)
Ingress Class: nginx
Address: 192.168.49.2
```

#### Проблемы с доступом
- **Prometheus**: Нет Ingress правила, доступ только через port-forward
- **Alertmanager**: Нет Ingress правила, доступ только через port-forward
- **SSL/TLS**: Не настроен для существующих Ingress

## Persistent Storage

### StorageClass
- **Default**: standard (вероятно hostPath в Minikube)

### PersistentVolumes
- Prometheus данные (автоматически созданные через StatefulSet)
- Grafana данные (если используется PVC)

## Текущие проблемы и ограничения

1. **Доступ к сервисам**:
   - Prometheus и Alertmanager доступны только через port-forward
   - Отсутствие SSL/TLS шифрования
   - Зависимость от NodePort для Grafana

2. **Безопасность**:
   - Использование простого пароля для Grafana (admin123)
   - Отсутствие настроенного RBAC для мониторинга
   - Отсутствие Network Policies

3. **Масштабируемость**:
   - Single-node кластер (Minikube)
   - Ограниченные ресурсы для хранения метрик

4. **Мониторинг**:
   - Базовая конфигурация без кастомных метрик
   - Отсутствие алертов
   - Стандартные дашборды без кастомизации

## Схема зависимостей компонентов

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   API Server    │────│   Controller    │────│   Scheduler     │
│   :8443         │    │   Manager       │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │      etcd       │
                    │   (storage)     │
                    └─────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                           Node: minikube                            │
├─────────────────┬─────────────────┬─────────────────┬───────────────┤
│     kubelet     │   kube-proxy    │  Container RT   │  Node Exporter│
│   (pod mgmt)    │  (networking)   │   (Docker)      │  (monitoring) │
└─────────────────┴─────────────────┴─────────────────┴───────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                        Application Layer                            │
├─────────────────┬─────────────────┬─────────────────┬───────────────┤
│   Prometheus    │     Grafana     │  Alertmanager   │ kube-state-   │
│  (StatefulSet)  │  (Deployment)   │ (StatefulSet)   │ metrics       │
│   Port: 9090    │   Port: 3000    │   Port: 9093    │ (Deployment)  │
└─────────────────┴─────────────────┴─────────────────┴───────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                          Network Layer                              │
├─────────────────┬─────────────────┬─────────────────────────────────┤
│  Ingress-nginx  │   Services      │          Ingress Rules          │
│  Controller     │   (ClusterIP,   │                                 │
│  (LoadBalancer) │   NodePort)     │  grafana.local -> grafana:80   │
└─────────────────┴─────────────────┴─────────────────────────────────┘
```

## Текущие пути доступа

### Внутрикластерные подключения
- Prometheus -> kube-state-metrics (service discovery)
- Prometheus -> Node Exporter (service discovery) 
- Grafana -> Prometheus (data source)
- Alertmanager -> Prometheus (alerts)

### Внешний доступ
1. **Grafana**: 
   - http://192.168.49.2:31282 (NodePort)
   - http://grafana.local (Ingress, требует /etc/hosts)
   
2. **Prometheus**: 
   - kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090
   
3. **Alertmanager**:
   - kubectl port-forward svc/prometheus-kube-prometheus-alertmanager 9093:9093

## Следующие шаги для улучшения

1. Создать Ingress для Prometheus и Alertmanager
2. Настроить SSL/TLS сертификаты
3. Улучшить безопасность (RBAC, Network Policies)
4. Добавить кастомные метрики и алерты
5. Создать обучающие материалы и примеры
