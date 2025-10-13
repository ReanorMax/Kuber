# Руководство по диагностике и устранению проблем в Kubernetes

## Общий подход к диагностике

### Пошаговый процесс диагностики

1. **Определите симптомы** - что именно не работает?
2. **Соберите информацию** - статус объектов, логи, события
3. **Проанализируйте данные** - найдите корневую причину
4. **Примените исправление** - устраните проблему
5. **Проверьте результат** - убедитесь что проблема решена

### Основные команды диагностики

```bash
# Общий статус кластера
kubectl cluster-info
kubectl get nodes
kubectl get componentstatuses

# Статус ресурсов
kubectl get all -A
kubectl get events --sort-by='.lastTimestamp' -A

# Детальная диагностика
kubectl describe <resource> <name> -n <namespace>
kubectl logs <pod-name> -c <container> -n <namespace>
kubectl exec -it <pod-name> -n <namespace> -- <command>
```

## Типичные проблемы и их решения

### 1. Pod не запускается

#### Симптомы:
- Pod в статусе `Pending`, `ImagePullBackOff`, `CrashLoopBackOff`
- Приложение недоступно

#### Диагностика:

```bash
# Проверить статус Pod'а
kubectl get pods -n <namespace>
kubectl describe pod <pod-name> -n <namespace>

# Проверить события
kubectl get events --field-selector involvedObject.name=<pod-name> -n <namespace>

# Проверить логи
kubectl logs <pod-name> -n <namespace>
kubectl logs <pod-name> -c <container-name> -n <namespace> --previous
```

#### Частые причины и решения:

**ImagePullBackOff:**
```bash
# Проверить правильность имени образа
kubectl describe pod <pod-name> | grep Image

# Проверить доступность образа
docker pull <image-name>

# Проверить imagePullSecrets
kubectl get secrets -n <namespace>
```

**CrashLoopBackOff:**
```bash
# Логи текущего контейнера
kubectl logs <pod-name> -n <namespace>

# Логи предыдущего контейнера
kubectl logs <pod-name> -n <namespace> --previous

# Проверить liveness/readiness probes
kubectl describe pod <pod-name> -n <namespace> | grep -A 5 "Liveness\|Readiness"
```

**Pending (нехватка ресурсов):**
```bash
# Проверить ресурсы узлов
kubectl describe nodes
kubectl top nodes

# Проверить resource requests в Pod'е
kubectl describe pod <pod-name> -n <namespace> | grep -A 5 "Requests\|Limits"
```

### 2. Сетевые проблемы

#### Симптомы:
- Приложения не могут подключиться друг к другу
- Внешний доступ не работает
- DNS резолвинг не работает

#### Диагностика сети:

```bash
# Тест Pod для диагностики сети
kubectl run netshoot --image=nicolaka/netshoot -i --tty --rm -- bash

# Внутри netshoot Pod'а:
# Тест DNS
nslookup kubernetes.default.svc.cluster.local
nslookup <service-name>.<namespace>.svc.cluster.local

# Тест подключения к Service
curl http://<service-name>.<namespace>.svc.cluster.local:<port>

# Тест подключения к Pod напрямую
curl http://<pod-ip>:<port>

# Проверка маршрутизации
traceroute <ip>
ping <ip>
```

#### Проверка Service и Endpoints:

```bash
# Статус Service
kubectl get svc -n <namespace>
kubectl describe svc <service-name> -n <namespace>

# Проверка Endpoints
kubectl get endpoints <service-name> -n <namespace>

# Если Endpoints пустые, проверить селекторы
kubectl get pods -n <namespace> --show-labels
```

#### Диагностика Ingress:

```bash
# Статус Ingress
kubectl get ingress -n <namespace>
kubectl describe ingress <ingress-name> -n <namespace>

# Проверка Ingress Controller
kubectl get pods -n ingress-nginx
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller

# Проверка DNS записей
nslookup <hostname>
curl -H "Host: <hostname>" http://<cluster-ip>
```

### 3. Проблемы с хранилищем

#### Симптомы:
- Pod не может подмонтировать том
- Данные не сохраняются
- Ошибки доступа к файлам

#### Диагностика:

```bash
# Статус PV и PVC
kubectl get pv
kubectl get pvc -n <namespace>
kubectl describe pvc <pvc-name> -n <namespace>

# Проверка StorageClass
kubectl get storageclass
kubectl describe storageclass <storage-class>

# Проверка монтирования внутри Pod'а
kubectl exec -it <pod-name> -n <namespace> -- df -h
kubectl exec -it <pod-name> -n <namespace> -- ls -la <mount-path>
```

### 4. Проблемы с ресурсами

#### Диагностика потребления ресурсов:

```bash
# Использование ресурсов узлами
kubectl top nodes
kubectl describe nodes | grep -A 5 "Allocated resources"

# Использование ресурсов Pod'ами
kubectl top pods -n <namespace>
kubectl describe pod <pod-name> -n <namespace> | grep -A 10 "Containers\|Resources"

# События связанные с ресурсами
kubectl get events --field-selector reason=FailedScheduling -A
kubectl get events --field-selector reason=OOMKilled -A
```

## Диагностика мониторинг стека

### Проблемы с Prometheus

```bash
# Статус Prometheus Pod'а
kubectl get pods -n monitoring -l app.kubernetes.io/name=prometheus
kubectl logs -n monitoring statefulset/prometheus-prometheus-kube-prometheus-prometheus

# Проверка конфигурации Prometheus
kubectl exec -n monitoring prometheus-prometheus-kube-prometheus-prometheus-0 -- promtool check config /etc/prometheus/config_out/prometheus.env.yaml

# Проверка targets в Prometheus UI
# Откройте https://prometheus.local/targets

# Проверка Service Discovery
kubectl get servicemonitor -A
kubectl describe servicemonitor <name> -n <namespace>
```

### Проблемы с Grafana

```bash
# Статус Grafana Pod'а
kubectl get pods -n monitoring -l app.kubernetes.io/name=grafana
kubectl logs -n monitoring deployment/prometheus-grafana -c grafana

# Проверка конфигурации
kubectl exec -n monitoring deployment/prometheus-grafana -c grafana -- ls -la /etc/grafana/
kubectl get configmap prometheus-grafana -n monitoring -o yaml

# Проверка подключения к Prometheus
kubectl exec -n monitoring deployment/prometheus-grafana -c grafana -- curl http://prometheus-kube-prometheus-prometheus.monitoring.svc.cluster.local:9090/api/v1/status/config
```

### Проблемы с Ingress

```bash
# Статус Ingress Controller
kubectl get pods -n ingress-nginx
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller

# Проверка конфигурации nginx
kubectl exec -n ingress-nginx deployment/ingress-nginx-controller -- nginx -T | grep -A 10 -B 5 "server_name.*local"

# Тест HTTP запросов
curl -I http://grafana.local
curl -I https://grafana.local
curl -k -I https://grafana.local  # Игнорировать SSL ошибки
```

## Производительность и оптимизация

### Диагностика производительности

```bash
# CPU и Memory узлов
kubectl top nodes

# Самые "тяжелые" Pod'ы
kubectl top pods -A --sort-by=cpu
kubectl top pods -A --sort-by=memory

# Детализация ресурсов по контейнерам
kubectl top pods -n <namespace> --containers

# Проверка лимитов и запросов
kubectl describe limitrange -A
kubectl describe resourcequota -A
```

### Оптимизация ресурсов

```bash
# Рекомендации VPA (если установлен)
kubectl get vpa -A
kubectl describe vpa <vpa-name>

# Анализ HPA
kubectl get hpa -A
kubectl describe hpa <hpa-name>

# Метрики автоскейлинга
kubectl get --raw "/apis/metrics.k8s.io/v1beta1/nodes"
kubectl get --raw "/apis/metrics.k8s.io/v1beta1/pods"
```

## Безопасность и RBAC

### Диагностика проблем доступа

```bash
# Проверка разрешений
kubectl auth can-i <verb> <resource> --as=<user>
kubectl auth can-i <verb> <resource> --as=system:serviceaccount:<namespace>:<sa-name>

# Анализ RBAC
kubectl get clusterrole <role-name> -o yaml
kubectl get clusterrolebinding <binding-name> -o yaml

# ServiceAccount Pod'а
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.serviceAccount}'
kubectl describe serviceaccount <sa-name> -n <namespace>
```

### Диагностика Network Policies

```bash
# Список Network Policies
kubectl get networkpolicy -A

# Тест подключения между Pod'ами
kubectl exec -it <source-pod> -- curl <target-service>:<port>

# Анализ политик
kubectl describe networkpolicy <policy-name> -n <namespace>
```

## Автоматические скрипты диагностики

### Скрипт комплексной диагностики

```bash
#!/bin/bash
# Файл: scripts/diagnose-cluster.sh

echo "=== Kubernetes Cluster Diagnostics ==="

echo "1. Cluster Info:"
kubectl cluster-info

echo -e "\n2. Node Status:"
kubectl get nodes -o wide

echo -e "\n3. System Pods:"
kubectl get pods -n kube-system

echo -e "\n4. Recent Events (last 1h):"
kubectl get events --sort-by='.lastTimestamp' -A | head -20

echo -e "\n5. Failed Pods:"
kubectl get pods -A --field-selector=status.phase=Failed

echo -e "\n6. Pods with High Restart Count:"
kubectl get pods -A --sort-by='.status.containerStatuses[0].restartCount' | tail -10

echo -e "\n7. Resource Usage:"
kubectl top nodes 2>/dev/null || echo "Metrics server not available"
kubectl top pods -A --sort-by=memory 2>/dev/null | head -10

echo -e "\n8. Ingress Status:"
kubectl get ingress -A

echo -e "\n9. PVC Status:"
kubectl get pvc -A

echo -e "\n10. Services without Endpoints:"
for ns in $(kubectl get ns -o name | cut -d/ -f2); do
    kubectl get endpoints -n $ns -o json | jq -r '.items[] | select(.subsets == null or .subsets == []) | "\(.metadata.namespace)/\(.metadata.name)"' 2>/dev/null
done

echo -e "\nDiagnostics complete!"
```

### Скрипт диагностики конкретного приложения

```bash
#!/bin/bash
# Файл: scripts/diagnose-app.sh

APP_NAME=${1:-""}
NAMESPACE=${2:-"default"}

if [ -z "$APP_NAME" ]; then
    echo "Usage: $0 <app-name> [namespace]"
    exit 1
fi

echo "=== Diagnosing application: $APP_NAME in namespace: $NAMESPACE ==="

echo "1. Deployment Status:"
kubectl get deployment $APP_NAME -n $NAMESPACE 2>/dev/null || echo "Deployment not found"

echo -e "\n2. Pod Status:"
kubectl get pods -l app=$APP_NAME -n $NAMESPACE

echo -e "\n3. Service Status:"
kubectl get svc -l app=$APP_NAME -n $NAMESPACE

echo -e "\n4. Recent Events for $APP_NAME:"
kubectl get events --field-selector involvedObject.name=$APP_NAME -n $NAMESPACE

echo -e "\n5. Pod Logs (last 20 lines):"
POD_NAME=$(kubectl get pods -l app=$APP_NAME -n $NAMESPACE -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$POD_NAME" ]; then
    kubectl logs $POD_NAME -n $NAMESPACE --tail=20
else
    echo "No pods found for app: $APP_NAME"
fi

echo -e "\n6. Resource Usage:"
kubectl top pods -l app=$APP_NAME -n $NAMESPACE 2>/dev/null || echo "Metrics not available"

echo -e "\nDiagnostics complete for $APP_NAME!"
```

## Полезные инструменты

### kubectl плагины

```bash
# Установка krew (менеджер плагинов)
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

# Полезные плагины
kubectl krew install ctx      # Быстрое переключение контекстов
kubectl krew install ns       # Быстрое переключение namespace'ов  
kubectl krew install tree     # Визуализация ресурсов как дерево
kubectl krew install top      # Расширенная информация о потреблении ресурсов
```

### Мониторинг в реальном времени

```bash
# Мониторинг Pod'ов в реальном времени
watch 'kubectl get pods -n monitoring'

# Мониторинг событий
kubectl get events -w

# Мониторинг автоскейлинга
watch 'kubectl get hpa'

# Мониторинг ресурсов
watch 'kubectl top nodes && echo && kubectl top pods -A --sort-by=memory | head -10'
```

## Чек-лист для диагностики

### При проблемах с доступностью приложения:

- [ ] Pod запущен и в состоянии `Running`?
- [ ] Service существует и имеет Endpoints?
- [ ] Ingress правильно настроен?
- [ ] DNS записи корректны?
- [ ] Сетевые политики не блокируют трафик?
- [ ] SSL сертификаты действительны?

### При проблемах с производительностью:

- [ ] Достаточно ресурсов на узлах?
- [ ] Pod'ы не достигают лимитов CPU/Memory?
- [ ] Нет частых перезапусков Pod'ов?
- [ ] HPA правильно настроен?
- [ ] Persistent Volumes не переполнены?

### При проблемах с безопасностью:

- [ ] ServiceAccount имеет необходимые разрешения?
- [ ] RBAC правила корректны?
- [ ] Pod Security Standards соблюдены?
- [ ] Network Policies не слишком ограничительны?
- [ ] Secrets правильно настроены и доступны?

## Заключение

Эффективная диагностика Kubernetes требует:
1. **Системного подхода** - следуйте методичному процессу
2. **Знания архитектуры** - понимайте как взаимодействуют компоненты
3. **Практики** - регулярно используйте команды диагностики
4. **Автоматизации** - создавайте скрипты для частых проверок
5. **Мониторинга** - настройте проактивное отслеживание проблем

Помните: большинство проблем в Kubernetes связано с неправильной конфигурацией, а не с багами в самой платформе.
