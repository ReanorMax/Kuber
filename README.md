# Kubernetes Learning Project

Проект для изучения Kubernetes с настроенным мониторингом стеком (Prometheus, Grafana, Alertmanager).

## Структура проекта

```
kubernetes-learning/
├── docs/                              # Документация
│   ├── current-architecture.md        # Текущая архитектура кластера
│   ├── architecture-diagram.md        # Диаграммы архитектуры  
│   └── component-dependencies.md      # Зависимости компонентов
├── manifests/                         # Kubernetes манифесты
│   ├── monitoring/                    # Мониторинг ресурсы
│   │   ├── services.yaml             # Экспортированные сервисы
│   │   └── workloads.yaml            # Deployments, StatefulSets, etc.
│   ├── ingress/                      # Ingress правила
│   │   └── grafana-ingress.yaml      # Текущий Ingress для Grafana
│   └── apps/                         # Пользовательские приложения
├── helm-values/                       # Helm значения
│   ├── prometheus-values.yaml         # Текущие значения
│   └── custom-prometheus-values.yaml  # Улучшенные значения
└── scripts/                          # Скрипты автоматизации
    ├── deploy-monitoring.sh          # Развертывание мониторинга
    ├── setup-dns.sh                 # Настройка /etc/hosts
    └── cluster-info.sh               # Информация о кластере
```

## Быстрый старт

### Предварительные требования

- Minikube установлен и запущен
- kubectl настроен для работы с кластером  
- Helm 3.x установлен

### Установка улучшенного мониторинга

1. **Развертывание мониторинга с Ingress:**
   ```bash
   cd scripts
   ./deploy-monitoring.sh
   ```

2. **Настройка DNS для локального доступа:**
   ```bash
   ./setup-dns.sh
   ```

3. **Проверка статуса:**
   ```bash
   ./cluster-info.sh
   ```

### Доступ к сервисам

После настройки будут доступны следующие сервисы:

- **Grafana**: http://grafana.local (admin/admin123)
- **Prometheus**: http://prometheus.local  
- **Alertmanager**: http://alertmanager.local

Альтернативные способы доступа:
- Grafana через NodePort: http://$(minikube ip):31282
- Port-forward: `kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80`

## Текущая архитектура

### Компоненты кластера
- **Кластер**: Minikube v1.34.0 (single-node)
- **Мониторинг**: kube-prometheus-stack через Helm
- **Ingress**: Nginx Ingress Controller
- **Доступ**: Ingress + NodePort + port-forward

### Namespace организация
- `monitoring` - Prometheus, Grafana, Alertmanager
- `ingress-nginx` - Nginx Ingress Controller  
- `kube-system` - Системные компоненты Kubernetes

## План обучения

### Фаза 1: Основы ✅
- [x] Анализ текущей архитектуры
- [x] Экспорт конфигураций
- [ ] Настройка постоянного доступа через Ingress

### Фаза 2: Углубленное изучение
- [ ] Kubernetes объекты (Pods, Deployments, Services)
- [ ] Сетевая модель и Service Discovery
- [ ] ConfigMaps и Secrets
- [ ] PersistentVolumes и Storage

### Фаза 3: Мониторинг и наблюдаемость  
- [ ] Prometheus архитектура и PromQL
- [ ] Создание кастомных дашбордов Grafana
- [ ] Настройка алертов в Alertmanager
- [ ] Добавление кастомных метрик

### Фаза 4: Продвинутые темы
- [ ] RBAC и безопасность
- [ ] Network Policies
- [ ] Horizontal Pod Autoscaler
- [ ] Переход на multi-node кластер

## Полезные команды

### Мониторинг кластера
```bash
# Статус всех ресурсов
kubectl get all -A

# Поды в мониторинге  
kubectl get pods -n monitoring

# Логи Grafana
kubectl logs -n monitoring deployment/prometheus-grafana -f

# Helm релизы
helm list -A
```

### Отладка сети
```bash
# Ingress правила
kubectl get ingress -A

# Сервисы и их endpoints
kubectl get svc,endpoints -n monitoring

# События кластера
kubectl get events --sort-by='.lastTimestamp'
```

### Прямой доступ (port-forward)
```bash
# Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80

# Prometheus  
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090

# Alertmanager
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-alertmanager 9093:9093
```

## Troubleshooting

### Проблемы с доступом через Ingress
1. Проверить статус Ingress Controller:
   ```bash
   kubectl get pods -n ingress-nginx
   ```

2. Проверить DNS записи в /etc/hosts:
   ```bash
   cat /etc/hosts | grep local
   ```

3. Проверить правила Ingress:
   ```bash
   kubectl describe ingress -n monitoring
   ```

### Проблемы с Prometheus
1. Проверить статус подов:
   ```bash
   kubectl get pods -n monitoring | grep prometheus
   ```

2. Проверить логи:
   ```bash
   kubectl logs -n monitoring statefulset/prometheus-prometheus-kube-prometheus-prometheus
   ```

### Восстановление /etc/hosts
```bash
sudo mv /etc/hosts.backup.* /etc/hosts
```

## Следующие шаги

1. **Настроить SSL/TLS** для Ingress правил
2. **Добавить кастомные метрики** и ServiceMonitors  
3. **Создать алерты** и правила в Alertmanager
4. **Развернуть пример приложения** с мониторингом
5. **Изучить RBAC** и настройки безопасности

## Ресурсы для изучения

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Helm Documentation](https://helm.sh/docs/)
