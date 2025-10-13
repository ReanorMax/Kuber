# 📦 ConfigMaps - Полное объяснение

> 📚 **Навигация**: [← Назад к INDEX](INDEX.md) | [🏠 Главная](../README.md)

## 🤔 **Что такое ConfigMap?**

**ConfigMap** - это объект Kubernetes для хранения **конфигурационных данных** в формате "ключ-значение".

### **Простыми словами**:
- 📝 **ConfigMap** = файл конфигурации в Kubernetes
- 🔧 Хранит настройки приложений (не чувствительные данные!)
- 📦 Отделяет конфигурацию от кода
- ♻️ Можно менять без пересборки образа

### **Что НЕ ConfigMap**:
- ❌ **НЕ для секретов** (пароли, токены) → используйте **Secret**
- ❌ **НЕ для больших файлов** (> 1MB) → используйте **Volumes**
- ❌ **НЕ база данных** → используйте настоящую БД

---

## 📊 **Анализ ConfigMap'ов в нашем кластере**

У нас **54 ConfigMap'а**! Давайте разберемся почему так много:

### **Категория 1: Системные (Kubernetes автоматически создает)** 🤖

```bash
# В каждом namespace автоматически:
kube-root-ca.crt          # Корневой сертификат CA
```

**Назначение**: Kubernetes **автоматически** создает в каждом namespace для доверия к API серверу.

**Количество**: 9 штук (по одному в каждом namespace)

**Система сама понимает?** ✅ Да! Автоматически монтируется в каждый Pod.

---

### **Категория 2: Системные конфигурации Kubernetes** ⚙️

```bash
# kube-system namespace:
coredns                                    # Конфиг DNS сервера
kube-proxy                                 # Конфиг сетевого прокси
kubeadm-config                            # Конфиг kubeadm
kubelet-config                            # Конфиг kubelet
extension-apiserver-authentication        # Аутентификация
kube-apiserver-legacy-service-account-token-tracking  # Отслеживание токенов
```

**Назначение**: Конфигурация компонентов Kubernetes

**Создал**: Kubernetes при инициализации кластера

**Система сама понимает?** ✅ Да! Компоненты K8s знают свои ConfigMap'ы.

---

### **Категория 3: Grafana Dashboards (Prometheus Stack)** 📊

```bash
# monitoring namespace (28 штук!):
prometheus-kube-prometheus-alertmanager-overview
prometheus-kube-prometheus-apiserver
prometheus-kube-prometheus-cluster-total
prometheus-kube-prometheus-k8s-resources-cluster
prometheus-kube-prometheus-k8s-resources-namespace
prometheus-kube-prometheus-k8s-resources-node
prometheus-kube-prometheus-k8s-resources-pod
prometheus-kube-prometheus-nodes
prometheus-kube-prometheus-prometheus
... и еще 19 дашбордов
```

**Назначение**: **Готовые дашборды Grafana** в формате JSON

**Создал**: Helm chart `kube-prometheus-stack`

**Система сама понимает?** ✅ Да! Grafana **sidecar контейнер** следит за ConfigMap'ами с label `grafana_dashboard=1` и автоматически загружает их.

**Как это работает**:
1. Helm создает ConfigMap с JSON дашборда
2. Добавляет label: `grafana_dashboard: "1"`
3. Sidecar контейнер `grafana-sc-dashboard` видит новый ConfigMap
4. Автоматически загружает дашборд в Grafana
5. Дашборд появляется в UI

---

### **Категория 4: Конфигурации Prometheus/Grafana** 🔧

```bash
# monitoring namespace:
prometheus-grafana                         # Основной конфиг Grafana (grafana.ini)
prometheus-grafana-config-dashboards       # Provisioning дашбордов
prometheus-kube-prometheus-grafana-datasource  # Источник данных Prometheus
prometheus-prometheus-kube-prometheus-prometheus-rulefiles-0  # Правила алертов (35 файлов!)
```

**Назначение**: Конфигурационные файлы приложений

**Создал**: Helm chart

**Система сама понимает?** ⚠️ Частично:
- Grafana знает про свой `prometheus-grafana` (указан в Deployment)
- Sidecar'ы автоматически подхватывают по label'ам
- Prometheus Operator следит за своими ConfigMap'ами

---

### **Категория 5: Наши демо приложения** 🎯

```bash
# default namespace:
demo-config            # Наш демонстрационный ConfigMap
example-app-html       # HTML страница для примера

# monitoring namespace:
learning-dashboard     # Наш кастомный дашборд
```

**Назначение**: Примеры для обучения

**Создал**: Мы вручную

**Система сама понимает?** ❌ Нет! Мы должны **явно указать** в Pod'е.

---

### **Категория 6: Ingress Controller** 🌐

```bash
# ingress-nginx namespace:
ingress-nginx-controller   # Конфигурация Nginx Ingress
```

**Назначение**: Настройки Nginx Ingress Controller

**Создал**: Helm chart `ingress-nginx`

**Система сама понимает?** ✅ Да! Ingress Controller знает свой ConfigMap.

---

### **Категория 7: Kubernetes Dashboard** 🖥️

```bash
# kubernetes-dashboard namespace:
kubernetes-dashboard-settings   # Настройки Dashboard
```

**Назначение**: Сохранение настроек UI Dashboard

**Создал**: Kubernetes Dashboard

**Система сама понимает?** ✅ Да! Dashboard использует для хранения настроек.

---

### **Категория 8: Storage** 💾

```bash
# local-path-storage namespace:
local-path-config       # Конфиг local-path provisioner
```

**Назначение**: Конфигурация provisioner для local storage

**Создал**: Local Path Provisioner

**Система сама понимает?** ✅ Да! Provisioner использует этот ConfigMap.

---

## 🔍 **Как система понимает куда "тащить" ConfigMap?**

### **Способ 1: Явное указание в Pod/Deployment** (ручной)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: app
    image: nginx
    # Вариант 1: Как переменная окружения
    env:
    - name: API_KEY
      valueFrom:
        configMapKeyRef:
          name: demo-config        # ← Имя ConfigMap
          key: api_key             # ← Ключ внутри ConfigMap
    
    # Вариант 2: Как файл (volume)
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config       # ← Путь в контейнере
  
  volumes:
  - name: config-volume
    configMap:
      name: demo-config            # ← Имя ConfigMap
```

**Как это работает**:
- ❌ Система **НЕ сама** понимает
- ✅ Вы **явно указываете** в манифесте Pod'а
- 📝 Kubernetes монтирует ConfigMap согласно вашим инструкциям

---

### **Способ 2: Sidecar с автоматическим обнаружением** (автоматический) ⭐

```yaml
# Sidecar контейнер (например, в Grafana):
- name: grafana-sc-dashboard
  image: k8s-sidecar
  env:
  - name: LABEL                    # ← Искать ConfigMap с этим label
    value: grafana_dashboard
  - name: LABEL_VALUE
    value: "1"
  - name: FOLDER                   # ← Куда сохранять
    value: /tmp/dashboards
  - name: RESOURCE
    value: both                    # ← Смотреть ConfigMap и Secret
```

**Как это работает**:
1. ✅ Sidecar **следит** за Kubernetes API
2. 🔍 **Ищет** ConfigMap'ы с label `grafana_dashboard: "1"`
3. 📥 **Скачивает** содержимое ConfigMap'а
4. 💾 **Сохраняет** в `/tmp/dashboards`
5. 🔄 Основной контейнер Grafana **видит** новые файлы
6. 📊 Grafana **загружает** дашборды

**Пример**:
```yaml
# ConfigMap с дашбордом Grafana:
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-dashboard
  labels:
    grafana_dashboard: "1"    # ← Sidecar найдет по этому label!
data:
  dashboard.json: |
    { ... JSON дашборда ... }
```

---

### **Способ 3: Operator с автоматическим управлением** (самый умный) 🤖

```yaml
# Prometheus Operator следит за своими CRD:
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: my-alerts
spec:
  groups:
  - name: example
    rules:
    - alert: HighMemory
      expr: memory > 80
```

**Как это работает**:
1. ✅ Вы создаете CRD (Custom Resource Definition)
2. 🤖 Prometheus **Operator следит** за этими CRD
3. 📝 Operator **автоматически создает/обновляет** ConfigMap
4. 🔄 Operator **перезагружает** Prometheus с новой конфигурацией

**Магия**: Вы пишете простой YAML → Operator делает всю работу!

---

## 📋 **Примеры ConfigMap из нашего кластера**

### **Пример 1: Простой ConfigMap (ключ-значение)**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: demo-config
  namespace: default
data:
  api_key: demo123                              # ← Простое значение
  database_url: postgresql://localhost:5432/demo
```

**Использование**:
```bash
# Как переменная окружения:
env:
- name: API_KEY
  valueFrom:
    configMapKeyRef:
      name: demo-config
      key: api_key
```

---

### **Пример 2: ConfigMap с файлом конфигурации**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-grafana
  namespace: monitoring
data:
  grafana.ini: |                    # ← Целый файл!
    [analytics]
    check_for_updates = true
    [grafana_net]
    url = https://grafana.net
    [log]
    mode = console
    [paths]
    data = /var/lib/grafana/
```

**Использование**:
```bash
# Как файл (volume):
volumeMounts:
- name: config
  mountPath: /etc/grafana/grafana.ini
  subPath: grafana.ini              # ← Монтируем только этот файл

volumes:
- name: config
  configMap:
    name: prometheus-grafana
```

---

### **Пример 3: ConfigMap с JSON (Grafana Dashboard)**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-kube-prometheus-nodes
  namespace: monitoring
  labels:
    grafana_dashboard: "1"          # ← Sidecar найдет автоматически!
data:
  nodes.json: |
    {
      "dashboard": {
        "title": "Nodes",
        "panels": [ ... ]
      }
    }
```

**Использование**: Автоматически! Sidecar сам найдет и загрузит.

---

### **Пример 4: ConfigMap с множественными файлами**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-path-config
  namespace: local-path-storage
data:
  config.json: |
    { ... }
  setup: |
    #!/bin/bash
    ...
  teardown: |
    #!/bin/bash
    ...
  helperPod.yaml: |
    apiVersion: v1
    kind: Pod
    ...
```

**Использование**: Все файлы монтируются в одну директорию.

---

## 🔄 **Жизненный цикл ConfigMap**

### **1. Создание**

```bash
# Способ 1: Из YAML файла
kubectl apply -f configmap.yaml

# Способ 2: Из литерала (ключ-значение)
kubectl create configmap my-config --from-literal=key1=value1 --from-literal=key2=value2

# Способ 3: Из файла
kubectl create configmap my-config --from-file=config.txt

# Способ 4: Из директории
kubectl create configmap my-config --from-file=./config-dir/

# Способ 5: Через Helm (автоматически)
helm install my-app ./chart  # Helm создаст ConfigMap'ы из templates
```

---

### **2. Использование в Pod'е**

```yaml
# Вариант 1: Как переменные окружения (все ключи)
envFrom:
- configMapRef:
    name: demo-config

# Вариант 2: Как переменные окружения (конкретные ключи)
env:
- name: API_KEY
  valueFrom:
    configMapKeyRef:
      name: demo-config
      key: api_key

# Вариант 3: Как volume (все ключи = файлы)
volumes:
- name: config-volume
  configMap:
    name: demo-config
    # Каждый ключ → отдельный файл в /etc/config/

# Вариант 4: Как volume (конкретные ключи)
volumes:
- name: config-volume
  configMap:
    name: demo-config
    items:
    - key: api_key
      path: api-key.txt    # api_key → /etc/config/api-key.txt
```

---

### **3. Обновление**

```bash
# Обновить ConfigMap
kubectl edit configmap demo-config -n default

# Или через apply
kubectl apply -f configmap.yaml
```

**⚠️ Важно**: Pod'ы **НЕ перезапускаются** автоматически!

**Что происходит**:
- ✅ Файлы в volume **обновятся** (через ~1 минуту)
- ❌ Переменные окружения **НЕ обновятся** (нужен рестарт Pod'а)

**Решение**:
```bash
# Перезапустить Pod'ы для применения изменений
kubectl rollout restart deployment/my-app
```

---

### **4. Удаление**

```bash
# Удалить ConfigMap
kubectl delete configmap demo-config -n default

# ⚠️ Если Pod использует этот ConfigMap - он упадет!
```

---

## 🎯 **Практические примеры**

### **Задание 1: Посмотреть содержимое ConfigMap Grafana**

```bash
# Показать весь ConfigMap
kubectl get configmap prometheus-grafana -n monitoring -o yaml

# Показать только данные (grafana.ini)
kubectl get configmap prometheus-grafana -n monitoring -o jsonpath='{.data.grafana\.ini}'
```

---

### **Задание 2: Найти все Grafana дашборды**

```bash
# Все ConfigMap'ы с label grafana_dashboard
kubectl get configmap -n monitoring -l grafana_dashboard=1

# Результат: 28 дашбордов!
```

---

### **Задание 3: Посмотреть как Grafana использует ConfigMap**

```bash
# Deployment Grafana
kubectl get deployment prometheus-grafana -n monitoring -o yaml | grep -A 20 "configMap"
```

---

### **Задание 4: Создать свой ConfigMap**

```bash
# Создать
kubectl create configmap my-app-config \
  --from-literal=app_name=MyApp \
  --from-literal=app_version=1.0 \
  -n default

# Проверить
kubectl get configmap my-app-config -n default -o yaml

# Использовать в Pod'е
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  containers:
  - name: test
    image: busybox
    command: ['sh', '-c', 'echo "App: \$APP_NAME v\$APP_VERSION" && sleep 3600']
    envFrom:
    - configMapRef:
        name: my-app-config
EOF

# Проверить логи
kubectl logs test-pod
# Результат: App: MyApp v1.0
```

---

## 🔐 **ConfigMap vs Secret**

| Аспект | ConfigMap | Secret |
|--------|-----------|--------|
| **Назначение** | Конфигурация приложений | Чувствительные данные |
| **Примеры** | URL, настройки, флаги | Пароли, токены, ключи |
| **Хранение** | Обычный текст | Base64 encoded |
| **Шифрование** | Нет | Опционально (etcd encryption) |
| **В логах** | Видно | Скрыто |
| **Best practice** | Для публичных данных | Для приватных данных |

**Пример**:
```yaml
# ConfigMap - публичные данные
data:
  database_host: postgres.example.com
  database_port: "5432"

# Secret - приватные данные
data:
  database_password: cGFzc3dvcmQxMjM=  # password123 в base64
```

---

## 📊 **Сводка по нашим ConfigMap'ам**

### **Итого: 54 ConfigMap'а**

| Категория | Количество | Создатель | Автоматическое использование |
|-----------|------------|-----------|------------------------------|
| **kube-root-ca.crt** | 9 | Kubernetes | ✅ Да (каждый Pod) |
| **Система K8s** | 6 | Kubernetes | ✅ Да (компоненты K8s) |
| **Grafana Dashboards** | 28 | Helm | ✅ Да (sidecar) |
| **Prometheus/Grafana config** | 5 | Helm | ⚠️ Частично (Operator/sidecar) |
| **Наши демо** | 3 | Мы | ❌ Нет (явно указываем) |
| **Ingress** | 1 | Helm | ✅ Да (Ingress Controller) |
| **Dashboard** | 1 | Dashboard | ✅ Да (Dashboard) |
| **Storage** | 1 | Provisioner | ✅ Да (Provisioner) |

---

## 💡 **Главные выводы**

### **1. ConfigMap - это просто конфиг**
- 📝 Хранит настройки в формате ключ-значение
- 📄 Может содержать целые файлы
- ♻️ Отделяет конфигурацию от кода

### **2. Система понимает по-разному**:
- 🤖 **Автоматически**: kube-root-ca.crt, системные компоненты
- 🏷️ **По label'ам**: Grafana sidecar ищет `grafana_dashboard: "1"`
- 📝 **Явно указываем**: в Pod/Deployment манифесте
- 🎯 **Через Operator**: Prometheus Operator управляет своими ConfigMap'ами

### **3. Много ConfigMap'ов - это нормально**:
- ✅ Grafana: 28 дашбордов = 28 ConfigMap'ов
- ✅ Каждый namespace: свой kube-root-ca.crt
- ✅ Каждый компонент: своя конфигурация

### **4. Готовые конфиги**:
- ✅ Да! Helm charts создают **готовые** ConfigMap'ы
- ✅ Grafana dashboards - **готовые** визуализации
- ✅ Prometheus rules - **готовые** алерты

---

## 🔗 **Связанные документы**

### **Читать дальше**:
- [🔐 Secret vs ConfigMap](learning-guide-01-basics.md) - когда что использовать
- [🔍 Проверка переменных окружения](how-to-check-env-variables.md) - как ConfigMap'ы становятся переменными
- [📊 Prometheus Stack](prometheus-stack-components.md) - где используются ConfigMap'ы

### **Практика**:
- [📖 Урок 1: Основы](learning-guide-01-basics.md) - работа с ConfigMap
- [🖥️ Lens](LENS-QUICKSTART.md) - просмотр ConfigMap в GUI

### **Навигация**:
- [📚 Полный индекс документации](INDEX.md)
- [🏠 Главная страница](../README.md)

---

**Теперь вы понимаете ConfigMap'ы!** 🚀

*ConfigMap - это способ Kubernetes хранить конфигурацию отдельно от приложений. Система может автоматически находить их (по label'ам) или вы явно указываете в манифестах.*

