# Урок 3: Продвинутые темы Kubernetes

## Цель урока
Изучить продвинутые возможности Kubernetes: StatefulSets, Persistent Storage, RBAC, безопасность и автоскейлинг.

## Теоретические основы

### 1. StatefulSets vs Deployments

**StatefulSet** предназначен для stateful приложений:
- Стабильные сетевые идентификаторы (Pod names)
- Упорядоченное развертывание и удаление
- Persistent storage для каждого Pod'а
- Примеры: базы данных, кластеры, очереди сообщений

**В нашем стеке StatefulSets используются для:**
- Prometheus Server (хранение метрик)
- Alertmanager (состояние алертов)

### 2. Persistent Storage

**Компоненты хранилища:**
- **PersistentVolume (PV)** - ресурс хранилища в кластере
- **PersistentVolumeClaim (PVC)** - запрос на хранилище от пользователя
- **StorageClass** - тип хранилища и его параметры

### 3. RBAC (Role-Based Access Control)

**Компоненты RBAC:**
- **ServiceAccount** - учетная запись для Pod'ов
- **Role/ClusterRole** - набор разрешений
- **RoleBinding/ClusterRoleBinding** - связь пользователей/SA с ролями

## Практические упражнения

### Упражнение 1: Анализ StatefulSets

```bash
# Список StatefulSets в кластере
kubectl get statefulsets -A

# Подробная информация о Prometheus StatefulSet
kubectl describe statefulset prometheus-prometheus-kube-prometheus-prometheus -n monitoring

# Поды StatefulSet (обратите внимание на имена)
kubectl get pods -n monitoring -l app.kubernetes.io/name=prometheus

# PVC созданные StatefulSet'ом
kubectl get pvc -n monitoring
```

**Задания:**
1. Сколько реплик в Prometheus StatefulSet?
2. Какой PVC создан для Prometheus Pod'а?
3. Как именуются Pod'ы в StatefulSet? (prometheus-prometheus-kube-prometheus-prometheus-0, -1, etc.)

### Упражнение 2: Работа с Persistent Storage

```bash
# Информация о PersistentVolumes
kubectl get pv

# Подробности о PVC Prometheus'а
kubectl describe pvc prometheus-prometheus-kube-prometheus-prometheus-db-prometheus-prometheus-kube-prometheus-prometheus-0 -n monitoring

# StorageClasses в кластере
kubectl get storageclass

# Проверка данных внутри Pod'а
kubectl exec -n monitoring prometheus-prometheus-kube-prometheus-prometheus-0 -- ls -la /prometheus
kubectl exec -n monitoring prometheus-prometheus-kube-prometheus-prometheus-0 -- df -h /prometheus
```

**Задания:**
1. Какой размер диска выделен для Prometheus?
2. Какой StorageClass используется?
3. Сколько места занимают данные Prometheus?

### Упражнение 3: Создание собственного StatefulSet

Создадим простую базу данных с persistent storage:

```yaml
# manifests/apps/postgres-statefulset.yaml
apiVersion: v1
kind: Service
metadata:
  name: postgres-service
  namespace: default
spec:
  selector:
    app: postgres
  ports:
  - port: 5432
  clusterIP: None  # Headless service
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
  namespace: default
spec:
  serviceName: postgres-service
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:13
        env:
        - name: POSTGRES_DB
          value: testdb
        - name: POSTGRES_USER
          value: testuser
        - name: POSTGRES_PASSWORD
          value: testpass
        - name: PGDATA
          value: /var/lib/postgresql/data/pgdata
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: postgres-data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: postgres-data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: "standard"  # или ваш StorageClass
      resources:
        requests:
          storage: 1Gi
```

**Задания:**
1. Примените манифест и проверьте создание StatefulSet
2. Подключитесь к базе: `kubectl exec -it postgres-0 -- psql -U testuser -d testdb`
3. Создайте тестовую таблицу и данные
4. Удалите Pod и убедитесь что данные сохранились

### Упражнение 4: RBAC и безопасность

```bash
# ServiceAccounts в monitoring namespace
kubectl get serviceaccounts -n monitoring

# Роли и привязки для Prometheus
kubectl get clusterrole | grep prometheus
kubectl describe clusterrole prometheus-kube-prometheus-prometheus

# ClusterRoleBindings
kubectl get clusterrolebinding | grep prometheus
kubectl describe clusterrolebinding prometheus-kube-prometheus-prometheus

# Проверка разрешений ServiceAccount'а
kubectl auth can-i get pods --as=system:serviceaccount:monitoring:prometheus-kube-prometheus-prometheus
kubectl auth can-i list nodes --as=system:serviceaccount:monitoring:prometheus-kube-prometheus-prometheus
```

**Задания:**
1. Какие разрешения есть у ServiceAccount Prometheus?
2. Может ли Prometheus читать Pod'ы из других namespace'ов?
3. Какие ClusterRole используются для мониторинга?

### Упражнение 5: Создание собственного RBAC

```yaml
# manifests/security/custom-rbac.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: monitoring-reader
  namespace: default
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: monitoring-reader
rules:
- apiGroups: [""]
  resources: ["pods", "services", "nodes", "endpoints"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["metrics.k8s.io"]
  resources: ["pods", "nodes"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: monitoring-reader-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: monitoring-reader
subjects:
- kind: ServiceAccount
  name: monitoring-reader
  namespace: default
---
# Тестовый Pod с нашим ServiceAccount
apiVersion: v1
kind: Pod
metadata:
  name: rbac-test
  namespace: default
spec:
  serviceAccountName: monitoring-reader
  containers:
  - name: kubectl
    image: bitnami/kubectl:latest
    command: ["sleep", "3600"]
```

**Задания:**
1. Примените RBAC манифест
2. Протестируйте разрешения: `kubectl exec rbac-test -- kubectl get pods`
3. Попробуйте что-то запрещенное: `kubectl exec rbac-test -- kubectl delete pods --all`

### Упражнение 6: Автоскейлинг (HPA)

Сначала установим metrics-server (если не установлен):

```bash
# Проверка наличия metrics-server
kubectl get deployment metrics-server -n kube-system

# Если нет, установим
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Для Minikube может потребоваться patch
kubectl patch deployment metrics-server -n kube-system --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'
```

Создадим приложение с автоскейлингом:

```yaml
# manifests/apps/hpa-demo.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hpa-demo
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hpa-demo
  template:
    metadata:
      labels:
        app: hpa-demo
    spec:
      containers:
      - name: hpa-demo
        image: k8s.gcr.io/hpa-example
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
---
apiVersion: v1
kind: Service
metadata:
  name: hpa-demo-service
  namespace: default
spec:
  selector:
    app: hpa-demo
  ports:
  - port: 80
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: hpa-demo
  namespace: default
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: hpa-demo
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
```

**Тестирование автоскейлинга:**

```bash
# Примените манифест
kubectl apply -f manifests/apps/hpa-demo.yaml

# Проверьте статус HPA
kubectl get hpa

# Создайте нагрузку
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh
# Внутри контейнера:
while true; do wget -q -O- http://hpa-demo-service.default.svc.cluster.local; done

# В другом терминале наблюдайте автоскейлинг
kubectl get hpa hpa-demo --watch
kubectl get pods -l app=hpa-demo --watch
```

**Задания:**
1. При какой нагрузке начинается масштабирование?
2. Сколько времени занимает добавление новых Pod'ов?
3. Как быстро происходит scale-down после снятия нагрузки?

### Упражнение 7: Вертикальный автоскейлинг (VPA)

```bash
# Установка VPA (если не установлен)
git clone https://github.com/kubernetes/autoscaler.git
cd autoscaler/vertical-pod-autoscaler/
./hack/vpa-install.sh

# Создание VPA для нашего приложения
cat << EOF | kubectl apply -f -
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: hpa-demo-vpa
  namespace: default
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: hpa-demo
  updatePolicy:
    updateMode: "Auto"
  resourcePolicy:
    containerPolicies:
    - containerName: hpa-demo
      maxAllowed:
        cpu: 1
        memory: 500Mi
      minAllowed:
        cpu: 100m
        memory: 50Mi
EOF

# Мониторинг рекомендаций VPA
kubectl describe vpa hpa-demo-vpa
```

## Безопасность и лучшие практики

### Упражнение 8: Pod Security Standards

```yaml
# manifests/security/pod-security-policy.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: secure-namespace
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
---
# Безопасный Pod
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
  namespace: secure-namespace
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 1000
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: app
    image: nginx:1.20
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      runAsNonRoot: true
      runAsUser: 1000
      capabilities:
        drop:
        - ALL
    volumeMounts:
    - name: tmp-volume
      mountPath: /tmp
    - name: cache-volume
      mountPath: /var/cache/nginx
  volumes:
  - name: tmp-volume
    emptyDir: {}
  - name: cache-volume
    emptyDir: {}
```

### Упражнение 9: Network Policies

```yaml
# manifests/security/network-policies.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: monitoring-isolation
  namespace: monitoring
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/name: prometheus
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app.kubernetes.io/name: grafana
    ports:
    - protocol: TCP
      port: 9090
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
  egress:
  - to: []  # Разрешить исходящий трафик куда угодно
    ports:
    - protocol: TCP
      port: 443
    - protocol: TCP
      port: 53
    - protocol: UDP
      port: 53
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: default
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

## Мониторинг продвинутых метрик

### Упражнение 10: Кастомные метрики и ServiceMonitor

```yaml
# manifests/monitoring/custom-servicemonitor.yaml
apiVersion: v1
kind: Service
metadata:
  name: custom-app-metrics
  namespace: default
  labels:
    app: custom-app
spec:
  selector:
    app: custom-app
  ports:
  - name: metrics
    port: 8080
    targetPort: 8080
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: custom-app-monitor
  namespace: default
  labels:
    app: custom-app
    release: prometheus  # Важно для discovery
spec:
  selector:
    matchLabels:
      app: custom-app
  endpoints:
  - port: metrics
    interval: 30s
    path: /metrics
---
# Простое приложение с метриками
apiVersion: apps/v1
kind: Deployment
metadata:
  name: custom-app
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: custom-app
  template:
    metadata:
      labels:
        app: custom-app
    spec:
      containers:
      - name: metrics-app
        image: prom/node-exporter:latest
        ports:
        - containerPort: 9100
          name: metrics
```

### Упражнение 11: Alerting Rules

```yaml
# manifests/monitoring/custom-alerts.yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: custom-alerts
  namespace: monitoring
  labels:
    prometheus: kube-prometheus
    role: alert-rules
spec:
  groups:
  - name: custom.rules
    rules:
    - alert: HighCPUUsage
      expr: rate(container_cpu_usage_seconds_total[5m]) > 0.8
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High CPU usage detected"
        description: "Pod {{ $labels.pod }} has high CPU usage: {{ $value }}"
    
    - alert: PodCrashLooping
      expr: rate(kube_pod_container_status_restarts_total[15m]) > 0
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "Pod is crash looping"
        description: "Pod {{ $labels.pod }} is restarting frequently"
    
    - alert: PrometheusTargetDown
      expr: up == 0
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: "Prometheus target is down"
        description: "Target {{ $labels.instance }} of job {{ $labels.job }} is down"
```

## Домашнее задание

1. **StatefulSet проект:**
   - Создайте StatefulSet для Redis cluster'а (3 узла)
   - Настройте persistent storage для каждого узла
   - Проверьте что данные сохраняются при перезапуске Pod'ов

2. **RBAC исследование:**
   - Создайте ServiceAccount для разработчика с ограниченными правами
   - Разрешите только чтение Pod'ов и Services в определенном namespace
   - Протестируйте разрешения с помощью `kubectl auth can-i`

3. **Автоскейлинг тестирование:**
   - Настройте HPA для вашего hello-world приложения
   - Создайте скрипт для генерации нагрузки
   - Измерьте время реакции на изменение нагрузки

4. **Безопасность аудит:**
   - Проанализируйте безопасность текущего мониторинг стека
   - Создайте Network Policies для изоляции трафика
   - Настройте Pod Security Standards

5. **Кастомные метрики:**
   - Создайте приложение с собственными Prometheus метриками
   - Настройте ServiceMonitor для автоматического discovery
   - Создайте дашборд в Grafana и алерты

## Полезные команды

```bash
# StatefulSets и Storage
kubectl get statefulsets -A
kubectl get pv,pvc -A
kubectl describe storageclass

# RBAC
kubectl get serviceaccounts -A
kubectl auth can-i <verb> <resource> --as=<user/sa>
kubectl describe clusterrole <role-name>

# Автоскейлинг
kubectl get hpa
kubectl top pods
kubectl top nodes

# Безопасность
kubectl get networkpolicies -A
kubectl get podsecuritypolicy  # Deprecated в новых версиях
kubectl describe pod <pod-name> --show-events

# Мониторинг
kubectl get servicemonitors -A
kubectl get prometheusrules -A
```

## Что изучили
- ✅ StatefulSets и их отличия от Deployments
- ✅ Persistent Storage (PV, PVC, StorageClass)
- ✅ RBAC для контроля доступа
- ✅ Horizontal и Vertical Pod Autoscaling
- ✅ Pod Security Standards и Network Policies
- ✅ Кастомные метрики и ServiceMonitors
- ✅ Alerting Rules и уведомления
- ✅ Лучшие практики безопасности

## Следующие шаги
- Изучение Helm и управления пакетами
- GitOps и Continuous Deployment
- Service Mesh (Istio, Linkerd)
- Multi-cluster deployment
- Kubernetes операторы
