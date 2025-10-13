# Урок 1: Основы Kubernetes - Объекты и их взаимодействие

## Цель урока
Изучить основные объекты Kubernetes и понять как они взаимодействуют друг с другом на примере нашего мониторинг стека.

## Теоретические основы

### 1. Pod - базовая единица развертывания

**Pod** - это наименьшая развертываемая единица в Kubernetes, состоящая из одного или нескольких контейнеров.

**Характеристики Pod:**
- Контейнеры в Pod разделяют сеть и хранилище
- Pod имеет уникальный IP адрес в кластере
- Контейнеры могут общаться через localhost
- Pod обычно содержит один основной контейнер

### 2. Deployment - управление репликацией

**Deployment** управляет ReplicanSet'ами и обеспечивает декларативные обновления Pod'ов.

**Возможности Deployment:**
- Масштабирование (изменение количества реплик)
- Rolling updates (постепенное обновление)
- Rollback (откат к предыдущей версии)
- Гарантия доступности сервиса

### 3. Service - сетевое обнаружение

**Service** предоставляет стабильную точку доступа к группе Pod'ов.

**Типы Service:**
- **ClusterIP** - внутрикластерный доступ (по умолчанию)
- **NodePort** - доступ через порт узла
- **LoadBalancer** - внешний балансировщик нагрузки

### 4. ConfigMap и Secret - конфигурация

**ConfigMap** - хранение конфигурационных данных
**Secret** - хранение чувствительных данных (пароли, токены, сертификаты)

## Практические упражнения

### Упражнение 1: Исследование Pod'ов

Изучим Pod'ы в нашем мониторинг стеке:

```bash
# Получить список всех Pod'ов в monitoring namespace
kubectl get pods -n monitoring

# Подробная информация о Pod'е Grafana
kubectl describe pod -n monitoring -l app.kubernetes.io/name=grafana

# Логи контейнера Grafana
kubectl logs -n monitoring deployment/prometheus-grafana -c grafana

# Выполнение команды внутри Pod'а
kubectl exec -n monitoring deployment/prometheus-grafana -c grafana -- ls -la /var/lib/grafana
```

**Задания:**
1. Сколько контейнеров запущено в Pod'е Grafana? Проверьте через `kubectl describe`
2. Какой IP адрес у Pod'а Prometheus? Найдите через `kubectl get pods -o wide`
3. Изучите переменные окружения в контейнере Grafana

### Упражнение 2: Анализ Deployment'ов

```bash
# Список всех Deployment'ов
kubectl get deployments -n monitoring

# Подробная информация о Deployment Grafana
kubectl describe deployment prometheus-grafana -n monitoring

# История версий Deployment'а
kubectl rollout history deployment/prometheus-grafana -n monitoring

# Масштабирование Grafana до 2 реплик
kubectl scale deployment prometheus-grafana --replicas=2 -n monitoring

# Проверка масштабирования
kubectl get pods -n monitoring -l app.kubernetes.io/name=grafana
```

**Задания:**
1. Сколько реплик по умолчанию у Grafana Deployment'а?
2. Какая стратегия обновления используется? (RollingUpdate/Recreate)
3. После масштабирования до 2 реплик - получили ли вы 2 Pod'а Grafana?
4. Верните количество реплик обратно к 1

### Упражнение 3: Изучение Services

```bash
# Список всех Services
kubectl get services -n monitoring

# Подробная информация о Service Grafana
kubectl describe service prometheus-grafana -n monitoring

# Проверка Endpoints (Pod'ы за Service)
kubectl get endpoints prometheus-grafana -n monitoring

# Тестирование доступности сервиса изнутри кластера
kubectl run test-pod --image=curlimages/curl -i --tty --rm -- sh
# Внутри Pod'а выполните:
# curl http://prometheus-grafana.monitoring.svc.cluster.local
```

**Задания:**
1. Какой тип у Service для Grafana? (ClusterIP/NodePort/LoadBalancer)
2. На какой порт перенаправляется трафик с Service на Pod?
3. Сколько Endpoints у Service после масштабирования?

### Упражнение 4: ConfigMaps и Secrets

```bash
# Список ConfigMaps в monitoring
kubectl get configmaps -n monitoring

# Содержимое ConfigMap Grafana
kubectl describe configmap prometheus-grafana -n monitoring

# Список Secrets
kubectl get secrets -n monitoring

# Наш TLS Secret
kubectl describe secret monitoring-tls -n monitoring

# Содержимое Secret Grafana (закодированное)
kubectl get secret prometheus-grafana -n monitoring -o yaml
```

**Задания:**
1. Какие ConfigMap'ы используются для конфигурации Grafana?
2. В каком Secret хранится пароль администратора Grafana?
3. Проверьте наличие нашего TLS сертификата в Secret `monitoring-tls`

## Создание собственного приложения

### Упражнение 5: Деплой простого web-приложения

Создадим простое приложение для демонстрации концепций:

```yaml
# Создайте файл: manifests/apps/hello-world.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-world
  namespace: default
  labels:
    app: hello-world
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hello-world
  template:
    metadata:
      labels:
        app: hello-world
    spec:
      containers:
      - name: hello-world
        image: nginx:1.20
        ports:
        - containerPort: 80
        env:
        - name: MESSAGE
          value: "Hello from Kubernetes!"
        volumeMounts:
        - name: html-volume
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html-volume
        configMap:
          name: hello-world-html
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: hello-world-html
  namespace: default
data:
  index.html: |
    <!DOCTYPE html>
    <html>
    <head><title>Hello Kubernetes</title></head>
    <body>
    <h1>Привет из Kubernetes!</h1>
    <p>Это Pod: <span id="hostname"></span></p>
    <p>Время: <span id="time"></span></p>
    <script>
      document.getElementById('hostname').textContent = window.location.hostname;
      document.getElementById('time').textContent = new Date().toLocaleString();
    </script>
    </body>
    </html>
---
apiVersion: v1
kind: Service
metadata:
  name: hello-world-service
  namespace: default
spec:
  selector:
    app: hello-world
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: hello-world-ingress
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
            name: hello-world-service
            port:
              number: 80
```

**Задания:**
1. Примените манифест: `kubectl apply -f manifests/apps/hello-world.yaml`
2. Проверьте статус развертывания: `kubectl get all -l app=hello-world`
3. Добавьте `192.168.49.2 hello.local` в `/etc/hosts`
4. Откройте http://hello.local в браузере
5. Масштабируйте приложение до 3 реплик и понаблюдайте балансировку нагрузки

### Упражнение 6: Обновление приложения

```bash
# Обновляем образ приложения
kubectl set image deployment/hello-world hello-world=nginx:1.21 --record

# Следим за процессом обновления
kubectl rollout status deployment/hello-world

# История обновлений
kubectl rollout history deployment/hello-world

# Откат к предыдущей версии (если нужно)
# kubectl rollout undo deployment/hello-world
```

## Домашнее задание

1. **Исследование архитектуры:**
   - Создайте диаграмму взаимодействия Pod -> Service -> Ingress для вашего hello-world приложения
   - Определите какие порты используются на каждом уровне

2. **Эксперименты с масштабированием:**
   - Масштабируйте hello-world до 5 реплик
   - Удалите один Pod принудительно: `kubectl delete pod <pod-name>`
   - Наблюдайте как Kubernetes восстанавливает желаемое состояние

3. **Конфигурация через ConfigMap:**
   - Измените HTML содержимое в ConfigMap
   - Перезапустите Pod'ы для применения изменений
   - Проверьте обновления в браузере

4. **Сетевая диагностика:**
   - Создайте тестовый Pod: `kubectl run debug --image=nicolaka/netshoot -i --tty --rm`
   - Из него протестируйте доступность всех сервисов мониторинга
   - Изучите DNS записи кластера: `nslookup prometheus-grafana.monitoring.svc.cluster.local`

## Полезные команды для запоминания

```bash
# Основные команды для работы с объектами
kubectl get <resource>                    # Список ресурсов
kubectl describe <resource> <name>        # Подробная информация
kubectl logs <pod-name> [-c container]    # Логи контейнера
kubectl exec -it <pod-name> -- <command>  # Выполнение команд в Pod

# Применение манифестов
kubectl apply -f <file.yaml>             # Применить конфигурацию
kubectl delete -f <file.yaml>            # Удалить ресурсы

# Масштабирование и управление
kubectl scale deployment <name> --replicas=N    # Изменить количество реплик
kubectl rollout status deployment/<name>        # Статус развертывания
kubectl rollout history deployment/<name>       # История обновлений

# Отладка и диагностика
kubectl get events --sort-by='.lastTimestamp'  # События кластера
kubectl top pods                                # Использование ресурсов (если metrics-server установлен)
```

## Что изучили
- ✅ Основные объекты Kubernetes (Pod, Deployment, Service, ConfigMap, Secret, Ingress)
- ✅ Как объекты взаимодействуют друг с другом
- ✅ Практические навыки работы с kubectl
- ✅ Создание и развертывание собственного приложения
- ✅ Масштабирование и обновление приложений

## Следующий урок
В следующем уроке мы изучим:
- Persistent Volumes и хранилище данных
- StatefulSets на примере Prometheus
- Networking и Service Discovery
- Более сложные конфигурации мониторинга
