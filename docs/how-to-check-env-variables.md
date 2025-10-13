# 🔍 Как проверить переменные окружения в контейнере

## 📋 **Обзор**

Переменные окружения (Environment Variables) - это способ передачи конфигурации в контейнеры. Kubernetes позволяет определять их несколькими способами:
- **Прямо в манифесте** (`value`)
- **Из Secret** (`valueFrom: secretKeyRef`)
- **Из ConfigMap** (`valueFrom: configMapKeyRef`)
- **Из метаданных Pod'а** (`fieldRef`)

---

## 🖥️ **Способ 1: Через kubectl (консоль)**

### **Вариант 1А: `kubectl exec` - Все переменные** ⭐

**Самый простой способ - зайти в контейнер и вывести все переменные**:

```bash
# Формат:
kubectl exec -n <namespace> <pod-name> -c <container-name> -- env

# Пример для Grafana:
kubectl exec -n monitoring prometheus-grafana-5746c56648-xkdlt -c grafana -- env

# С сортировкой (удобнее читать):
kubectl exec -n monitoring prometheus-grafana-5746c56648-xkdlt -c grafana -- env | sort

# Поиск конкретной переменной:
kubectl exec -n monitoring prometheus-grafana-5746c56648-xkdlt -c grafana -- env | grep GF_
```

**Результат**:
```
GF_SECURITY_ADMIN_USER=admin
GF_SECURITY_ADMIN_PASSWORD=admin123
GF_PATHS_DATA=/var/lib/grafana/
GF_PATHS_LOGS=/var/log/grafana
GF_PATHS_PLUGINS=/var/lib/grafana/plugins
GF_PATHS_PROVISIONING=/etc/grafana/provisioning
POD_IP=10.244.0.37
KUBERNETES_SERVICE_HOST=10.96.0.1
...
```

**Преимущества**:
- ✅ Показывает **реальные значения** (даже из Secret)
- ✅ Включает **автоматические** переменные Kubernetes
- ✅ Самый быстрый способ

**Недостатки**:
- ❌ Не показывает **откуда** взята переменная (Secret/ConfigMap/прямое значение)

---

### **Вариант 1Б: `kubectl describe` - С источником переменных** ⭐

**Показывает переменные с указанием источника**:

```bash
# Формат:
kubectl describe pod <pod-name> -n <namespace>

# Пример для Grafana:
kubectl describe pod prometheus-grafana-5746c56648-xkdlt -n monitoring | grep -A 30 "Environment:"

# Только для контейнера grafana:
kubectl describe pod prometheus-grafana-5746c56648-xkdlt -n monitoring | grep -A 10 "grafana:" | grep -A 10 "Environment:"
```

**Результат**:
```
Environment:
  POD_IP:                       (v1:status.podIP)
  GF_SECURITY_ADMIN_USER:      <set to the key 'admin-user' in secret 'prometheus-grafana'>
  GF_SECURITY_ADMIN_PASSWORD:  <set to the key 'admin-password' in secret 'prometheus-grafana'>
  GF_PATHS_DATA:               /var/lib/grafana/
  GF_PATHS_LOGS:               /var/log/grafana
```

**Преимущества**:
- ✅ Показывает **источник** переменной (Secret/ConfigMap/прямое)
- ✅ Видно что из Secret (но не значение!)
- ✅ Полная картина конфигурации

**Недостатки**:
- ❌ Не показывает **значения** из Secret (только ссылку)

---

### **Вариант 1В: `kubectl get pod -o yaml` - YAML конфигурация**

**Показывает конфигурацию в формате YAML**:

```bash
# Формат:
kubectl get pod <pod-name> -n <namespace> -o yaml

# Пример для Grafana (только секция env):
kubectl get pod prometheus-grafana-5746c56648-xkdlt -n monitoring -o yaml | grep -A 20 "env:"

# В JSON формате:
kubectl get pod prometheus-grafana-5746c56648-xkdlt -n monitoring -o json | jq '.spec.containers[].env'
```

**Результат (YAML)**:
```yaml
env:
- name: POD_IP
  valueFrom:
    fieldRef:
      fieldPath: status.podIP
- name: GF_SECURITY_ADMIN_USER
  valueFrom:
    secretKeyRef:
      key: admin-user
      name: prometheus-grafana
- name: GF_SECURITY_ADMIN_PASSWORD
  valueFrom:
    secretKeyRef:
      key: admin-password
      name: prometheus-grafana
- name: GF_PATHS_DATA
  value: /var/lib/grafana/
```

**Преимущества**:
- ✅ Структурированный формат
- ✅ Показывает **точную конфигурацию**
- ✅ Подходит для анализа и копирования

**Недостатки**:
- ❌ Не показывает **реальные значения** из Secret

---

### **Вариант 1Г: Получить значение из Secret**

**Если переменная берется из Secret, можно посмотреть значение**:

```bash
# 1. Узнать имя Secret из describe:
kubectl describe pod prometheus-grafana-5746c56648-xkdlt -n monitoring | grep "secret 'prometheus-grafana'"
# Результат: secret 'prometheus-grafana'

# 2. Посмотреть Secret:
kubectl get secret prometheus-grafana -n monitoring -o yaml

# 3. Декодировать значение (base64):
kubectl get secret prometheus-grafana -n monitoring -o jsonpath='{.data.admin-user}' | base64 -d
# Результат: admin

kubectl get secret prometheus-grafana -n monitoring -o jsonpath='{.data.admin-password}' | base64 -d
# Результат: admin123
```

**Все в одной команде**:
```bash
# Показать все ключи Secret с декодированием:
kubectl get secret prometheus-grafana -n monitoring -o json | jq -r '.data | to_entries[] | "\(.key): \(.value | @base64d)"'
```

**Результат**:
```
admin-password: admin123
admin-user: admin
```

---

### **Вариант 1Д: Умная команда для анализа**

**Скрипт для полного анализа переменных**:

```bash
#!/bin/bash
POD="prometheus-grafana-5746c56648-xkdlt"
NAMESPACE="monitoring"
CONTAINER="grafana"

echo "📊 Анализ переменных окружения для $POD"
echo "==========================================="
echo ""

echo "🔍 Переменные из манифеста (с источниками):"
kubectl describe pod $POD -n $NAMESPACE | grep -A 20 "Environment:" | head -25
echo ""

echo "💻 Реальные значения в контейнере:"
kubectl exec -n $NAMESPACE $POD -c $CONTAINER -- env | grep GF_ | sort
echo ""

echo "🔐 Значения из Secret 'prometheus-grafana':"
kubectl get secret prometheus-grafana -n $NAMESPACE -o json | jq -r '.data | to_entries[] | "\(.key): \(.value | @base64d)"'
```

---

## 🖥️ **Способ 2: Через Lens (GUI)** ⭐

### **Шаг 1: Открыть Pod в Lens**

1. **Запустить Lens** на Windows
2. **Выбрать кластер** `kind-learning-cluster`
3. **Перейти**: Workloads → Pods
4. **Выбрать namespace**: `monitoring`
5. **Найти Pod**: `prometheus-grafana-...`
6. **Кликнуть** на Pod для открытия деталей

### **Шаг 2: Просмотреть переменные окружения**

#### **Вариант 2А: Через вкладку "Pod"**

1. В открытом Pod'е перейти на вкладку **"Pod"** (основная)
2. Прокрутить вниз до секции **"Containers"**
3. Найти контейнер **"grafana"**
4. Развернуть секцию **"Environment Variables"**

**Что увидите**:
```
POD_IP: 10.244.0.37 (from field: status.podIP)
GF_SECURITY_ADMIN_USER: *** (from secret: prometheus-grafana / admin-user)
GF_SECURITY_ADMIN_PASSWORD: *** (from secret: prometheus-grafana / admin-password)
GF_PATHS_DATA: /var/lib/grafana/
GF_PATHS_LOGS: /var/log/grafana
```

**Особенности**:
- ✅ Удобный визуальный интерфейс
- ✅ Показывает источник (Secret/ConfigMap/field)
- ❌ Скрывает значения из Secret (показывает `***`)

#### **Вариант 2Б: Через Shell (Terminal в Lens)**

1. В открытом Pod'е нажать кнопку **"Pod Shell"** (иконка терминала справа вверху)
2. **Выбрать контейнер**: `grafana` (если несколько)
3. В открывшемся терминале выполнить:

```bash
# Все переменные
env | sort

# Только Grafana переменные
env | grep GF_

# Конкретная переменная
echo $GF_SECURITY_ADMIN_USER
```

**Что увидите**:
```
GF_SECURITY_ADMIN_USER=admin
GF_SECURITY_ADMIN_PASSWORD=admin123
GF_PATHS_DATA=/var/lib/grafana/
...
```

**Особенности**:
- ✅ Показывает **реальные значения** (даже из Secret!)
- ✅ Интерактивный shell
- ✅ Можно выполнять любые команды

#### **Вариант 2В: Через YAML манифест**

1. В открытом Pod'е нажать кнопку **"Edit"** (иконка карандаша справа вверху)
2. В YAML редакторе найти секцию `spec.containers[].env`
3. Прокрутить до нужного контейнера

**Что увидите**:
```yaml
containers:
- name: grafana
  env:
  - name: POD_IP
    valueFrom:
      fieldRef:
        fieldPath: status.podIP
  - name: GF_SECURITY_ADMIN_USER
    valueFrom:
      secretKeyRef:
        name: prometheus-grafana
        key: admin-user
  - name: GF_PATHS_DATA
    value: /var/lib/grafana/
```

**Особенности**:
- ✅ Структурированный формат
- ✅ Видна полная конфигурация
- ❌ Не показывает значения из Secret

#### **Вариант 2Г: Просмотр Secret в Lens**

1. **Перейти**: Config → Secrets
2. **Выбрать namespace**: `monitoring`
3. **Найти Secret**: `prometheus-grafana`
4. **Кликнуть** для открытия деталей
5. Нажать **"Show"** / **"👁️"** рядом с ключом для просмотра значения

**Что увидите**:
```
admin-user: admin
admin-password: admin123
```

**Особенности**:
- ✅ Показывает декодированные значения
- ✅ Удобный UI
- ✅ Можно редактировать

---

## 📊 **Сравнение методов**

| Метод | Показывает значения Secret | Показывает источник | Удобство | Рекомендация |
|-------|---------------------------|---------------------|----------|--------------|
| **kubectl exec** | ✅ Да | ❌ Нет | ⭐⭐⭐ | **Лучше для быстрого просмотра значений** |
| **kubectl describe** | ❌ Нет | ✅ Да | ⭐⭐ | **Лучше для понимания источника** |
| **kubectl get -o yaml** | ❌ Нет | ✅ Да | ⭐⭐ | **Для анализа конфигурации** |
| **Lens Pod Shell** | ✅ Да | ❌ Нет | ⭐⭐⭐⭐ | **Самый удобный для интерактивной работы** |
| **Lens Pod Details** | ❌ Нет | ✅ Да | ⭐⭐⭐⭐⭐ | **Лучше для визуального анализа** |
| **Lens Secret View** | ✅ Да | - | ⭐⭐⭐⭐ | **Для просмотра Secret'ов** |

---

## 🎯 **Практическое задание**

### **Задание 1: Найти все переменные Grafana, начинающиеся с `GF_`**

**Через kubectl**:
```bash
kubectl exec -n monitoring prometheus-grafana-5746c56648-xkdlt -c grafana -- env | grep GF_
```

**Через Lens**:
1. Pod Shell → `env | grep GF_`

**Ожидаемый результат**: 6-7 переменных с префиксом `GF_`

---

### **Задание 2: Узнать источник переменной `GF_SECURITY_ADMIN_PASSWORD`**

**Через kubectl**:
```bash
kubectl describe pod prometheus-grafana-5746c56648-xkdlt -n monitoring | grep -A 1 "GF_SECURITY_ADMIN_PASSWORD"
```

**Ожидаемый результат**:
```
GF_SECURITY_ADMIN_PASSWORD:  <set to the key 'admin-password' in secret 'prometheus-grafana'>
```

**Через Lens**:
1. Pod Details → Containers → grafana → Environment Variables
2. Найти `GF_SECURITY_ADMIN_PASSWORD`

---

### **Задание 3: Получить значение пароля администратора**

**Вариант 1 - Через exec**:
```bash
kubectl exec -n monitoring prometheus-grafana-5746c56648-xkdlt -c grafana -- printenv GF_SECURITY_ADMIN_PASSWORD
```

**Вариант 2 - Через Secret**:
```bash
kubectl get secret prometheus-grafana -n monitoring -o jsonpath='{.data.admin-password}' | base64 -d
```

**Вариант 3 - Через Lens**:
1. Config → Secrets → prometheus-grafana
2. Нажать 👁️ рядом с `admin-password`

**Ожидаемый результат**: `admin123`

---

### **Задание 4: Найти переменную с IP адресом Pod'а**

**Через kubectl**:
```bash
kubectl exec -n monitoring prometheus-grafana-5746c56648-xkdlt -c grafana -- printenv POD_IP
```

**Через Lens**:
1. Pod Shell → `echo $POD_IP`

**Ожидаемый результат**: IP адрес вида `10.244.0.X`

---

## 💡 **Типы переменных окружения в Kubernetes**

### **1. Прямое значение (`value`)**

```yaml
env:
- name: GF_PATHS_DATA
  value: /var/lib/grafana/
```

**Использование**: Простые статические значения

### **2. Из Secret (`secretKeyRef`)**

```yaml
env:
- name: GF_SECURITY_ADMIN_PASSWORD
  valueFrom:
    secretKeyRef:
      name: prometheus-grafana
      key: admin-password
```

**Использование**: Чувствительные данные (пароли, токены)

### **3. Из ConfigMap (`configMapKeyRef`)**

```yaml
env:
- name: CONFIG_FILE_PATH
  valueFrom:
    configMapKeyRef:
      name: app-config
      key: config.yaml
```

**Использование**: Конфигурационные файлы, не чувствительные данные

### **4. Из метаданных Pod'а (`fieldRef`)**

```yaml
env:
- name: POD_IP
  valueFrom:
    fieldRef:
      fieldPath: status.podIP
- name: POD_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
```

**Использование**: Динамические значения от Kubernetes

### **5. Из ресурсов контейнера (`resourceFieldRef`)**

```yaml
env:
- name: CPU_LIMIT
  valueFrom:
    resourceFieldRef:
      resource: limits.cpu
```

**Использование**: Информация о ресурсах контейнера

---

## 🔍 **Автоматические переменные Kubernetes**

Kubernetes **автоматически добавляет** переменные окружения для каждого Service в том же namespace:

```bash
# Формат:
<SERVICE_NAME>_SERVICE_HOST=<ClusterIP>
<SERVICE_NAME>_SERVICE_PORT=<Port>
<SERVICE_NAME>_PORT_<PORT>_TCP_ADDR=<ClusterIP>
<SERVICE_NAME>_PORT_<PORT>_TCP_PORT=<Port>
<SERVICE_NAME>_PORT_<PORT>_TCP_PROTO=tcp
```

**Пример для Grafana**:
```
PROMETHEUS_GRAFANA_SERVICE_HOST=10.106.208.249
PROMETHEUS_GRAFANA_SERVICE_PORT=80
PROMETHEUS_GRAFANA_PORT_80_TCP_ADDR=10.106.208.249
PROMETHEUS_GRAFANA_PORT_80_TCP_PORT=80
PROMETHEUS_GRAFANA_PORT_80_TCP_PROTO=tcp
```

**Как проверить**:
```bash
kubectl exec -n monitoring prometheus-grafana-5746c56648-xkdlt -c grafana -- env | grep SERVICE_HOST
```

---

## 🎓 **Резюме**

### **Быстрый способ (kubectl)**:
```bash
# Все переменные с значениями:
kubectl exec -n <ns> <pod> -c <container> -- env | sort

# С источником (но без значений Secret):
kubectl describe pod <pod> -n <ns> | grep -A 20 "Environment:"

# Значение из Secret:
kubectl get secret <secret-name> -n <ns> -o jsonpath='{.data.<key>}' | base64 -d
```

### **Удобный способ (Lens)**:
1. **Pod Details** → Environment Variables (визуальный анализ)
2. **Pod Shell** → `env` (реальные значения)
3. **Secrets** → Show (просмотр Secret'ов)

### **Ключевые моменты**:
- ✅ `kubectl exec env` показывает **реальные значения**
- ✅ `kubectl describe` показывает **источники**
- ✅ Lens удобен для **визуального анализа**
- ✅ Secret значения **base64 encoded** в манифесте

**Теперь вы знаете все способы проверки переменных окружения!** 🚀

