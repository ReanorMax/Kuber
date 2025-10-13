# 📦 Pod vs Container - Полное объяснение

> 📚 **Навигация**: [← Назад к INDEX](INDEX.md) | [🏠 Главная](../README.md)


## 🤔 **В чем разница?**

### **Container (Контейнер)**:
- 🐳 **Docker контейнер** - изолированный процесс
- 📦 Один образ (image) = один контейнер
- 🔧 Выполняет одну задачу (приложение)
- Пример: `grafana/grafana:12.2.0`

### **Pod (Под)**:
- 🎯 **Группа из одного или нескольких контейнеров**
- 🌐 Общий сетевой namespace (один IP адрес)
- 💾 Общие volumes (файлы)
- ⚡ Общие ресурсы (CPU, память)
- Пример: Grafana Pod с 3 контейнерами

---

## 🔍 **Как проверить контейнеры в Pod'е?**

### **Способ 1: Краткая информация** (самый простой):
```bash
kubectl get pods -n <namespace>

# Результат:
# NAME                       READY   STATUS    RESTARTS   AGE
# prometheus-grafana-xxx     3/3     Running   0          15m
#                            ^^^
#                      3 контейнера из 3 работают
```

### **Способ 2: Список имен контейнеров**:
```bash
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].name}' | tr ' ' '\n'

# Результат для Grafana:
# grafana-sc-dashboard
# grafana-sc-datasources
# grafana
```

### **Способ 3: Подробная информация**:
```bash
kubectl describe pod <pod-name> -n <namespace>

# Смотрим раздел "Containers:"
# Показывает: имя, образ, порты, ресурсы, переменные окружения
```

### **Способ 4: JSON формат** (для автоматизации):
```bash
kubectl get pod <pod-name> -n <namespace> -o json | jq '.spec.containers[].name'
```

### **Способ 5: Таблица всех Pod'ов с контейнерами**:
```bash
kubectl get pods -n <namespace> -o custom-columns=NAME:.metadata.name,CONTAINERS:.spec.containers[*].name,READY:.status.containerStatuses[*].ready
```

---

## 📊 **Анализ нашего кластера**

### **Multi-container Pods** (несколько контейнеров):

#### 1. **Grafana Pod** - 3 контейнера:
```bash
kubectl get pod -n monitoring -l app.kubernetes.io/name=grafana -o jsonpath='{.items[0].spec.containers[*].name}'
# grafana-sc-dashboard grafana-sc-datasources grafana
```

**Контейнеры**:
- 📊 `grafana-sc-dashboard` - sidecar для автозагрузки дашбордов
- 🔌 `grafana-sc-datasources` - sidecar для автозагрузки источников данных
- 🎨 `grafana` - основное приложение Grafana

**Зачем?**
- Sidecar'ы следят за ConfigMap'ами
- При изменении ConfigMap автоматически обновляют конфигурацию
- Основной контейнер не знает о Kubernetes API

#### 2. **Prometheus Pod** - 2 контейнера:
```bash
kubectl get pod -n monitoring prometheus-prometheus-kube-prometheus-prometheus-0 -o jsonpath='{.spec.containers[*].name}'
# prometheus config-reloader
```

**Контейнеры**:
- 📈 `prometheus` - основной сервер Prometheus
- 🔄 `config-reloader` - перезагружает конфиг при изменениях

**Зачем?**
- `config-reloader` следит за ConfigMap с конфигурацией
- При изменении отправляет сигнал Prometheus для перезагрузки
- Нет необходимости перезапускать весь Pod

#### 3. **Alertmanager Pod** - 2 контейнера:
```bash
kubectl get pod -n monitoring alertmanager-prometheus-kube-prometheus-alertmanager-0 -o jsonpath='{.spec.containers[*].name}'
# alertmanager config-reloader
```

**Контейнеры**:
- 🚨 `alertmanager` - основной сервер Alertmanager
- 🔄 `config-reloader` - перезагружает конфиг при изменениях

### **Single-container Pods** (один контейнер):

#### 4. **Prometheus Operator** - 1 контейнер:
```bash
kubectl get pod -n monitoring -l app.kubernetes.io/name=kube-prometheus-stack -o jsonpath='{.items[0].spec.containers[*].name}'
# kube-prometheus-stack
```

**Контейнер**:
- ⚙️ `kube-prometheus-stack` - оператор для управления Prometheus/Alertmanager

#### 5. **Kube State Metrics** - 1 контейнер:
```bash
kubectl get pod -n monitoring -l app.kubernetes.io/name=kube-state-metrics -o jsonpath='{.items[0].spec.containers[*].name}'
# kube-state-metrics
```

**Контейнер**:
- 📊 `kube-state-metrics` - собирает метрики состояния объектов Kubernetes

#### 6. **Node Exporter** - 1 контейнер:
```bash
kubectl get pod -n monitoring -l app.kubernetes.io/name=prometheus-node-exporter -o jsonpath='{.items[0].spec.containers[*].name}'
# node-exporter
```

**Контейнер**:
- 🖥️ `node-exporter` - собирает метрики хоста (CPU, память, диск)

---

## 💡 **Зачем несколько контейнеров в одном Pod'е?**

### **Паттерн 1: Sidecar (Помощник)**
**Описание**: Дополнительный контейнер помогает основному

**Примеры**:
- 📊 Grafana + автозагрузка дашбордов
- 📝 Приложение + логгер (Fluentd, Filebeat)
- 🔐 Приложение + прокси для аутентификации

**Когда использовать**:
- Нужна автоматическая синхронизация данных
- Логирование или мониторинг
- Преобразование данных

### **Паттерн 2: Adapter (Адаптер)**
**Описание**: Преобразует данные для основного контейнера

**Примеры**:
- 🔄 Конвертация метрик в формат Prometheus
- 📄 Преобразование логов в JSON
- 🌐 HTTP → gRPC конвертер

**Когда использовать**:
- Несовместимость форматов данных
- Нужна трансформация на лету
- Стандартизация интерфейсов

### **Паттерн 3: Ambassador (Посредник)**
**Описание**: Прокси для сетевых запросов

**Примеры**:
- 🔒 Service Mesh (Istio Envoy, Linkerd)
- 🌐 Прокси для внешних API
- 🔐 TLS termination

**Когда использовать**:
- Нужен контроль трафика
- Service Mesh
- Централизованная аутентификация

### **Паттерн 4: Init Container (Инициализация)**
**Описание**: Запускается **перед** основным контейнером

**Примеры**:
- 📥 Загрузка конфигурации из Git
- 🗄️ Миграция базы данных
- ⏳ Ожидание доступности зависимостей

**Когда использовать**:
- Подготовка окружения
- Миграции
- Проверка зависимостей

---

## 🔧 **Практические упражнения**

### **Упражнение 1: Найти все multi-container Pod'ы**
```bash
# Показать Pod'ы с количеством контейнеров
kubectl get pods --all-namespaces -o json | jq -r '.items[] | select((.spec.containers | length) > 1) | "\(.metadata.namespace)/\(.metadata.name): \(.spec.containers | length) containers"'
```

### **Упражнение 2: Посмотреть логи конкретного контейнера**
```bash
# Логи основного контейнера Grafana
kubectl logs -n monitoring deployment/prometheus-grafana -c grafana --tail=20

# Логи sidecar'а дашбордов
kubectl logs -n monitoring deployment/prometheus-grafana -c grafana-sc-dashboard --tail=20
```

### **Упражнение 3: Проверить ресурсы каждого контейнера**
```bash
# Ресурсы всех контейнеров в Pod'е
kubectl get pod <pod-name> -n <namespace> -o json | jq '.spec.containers[] | {name: .name, resources: .resources}'
```

### **Упражнение 4: Создать свой multi-container Pod**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-multi-container-pod
spec:
  containers:
  - name: main-app
    image: nginx:alpine
    ports:
    - containerPort: 80
  
  - name: sidecar-logger
    image: busybox
    command: ['sh', '-c', 'tail -f /var/log/nginx/access.log']
    volumeMounts:
    - name: logs
      mountPath: /var/log/nginx
  
  volumes:
  - name: logs
    emptyDir: {}
```

---

## 📚 **Важные концепции**

### **1. Shared Network Namespace**
```bash
# Все контейнеры в Pod'е имеют ОДИН IP адрес
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.status.podIP}'

# Контейнеры общаются через localhost
# Пример: grafana-sc-dashboard → localhost:3000 → grafana
```

### **2. Shared Volumes**
```bash
# Контейнеры могут делить файлы через volumes
# Пример: 
# - sidecar пишет файл в /tmp/config
# - основной контейнер читает из /tmp/config
```

### **3. Lifecycle**
```bash
# Все контейнеры запускаются одновременно
# Pod считается Ready только когда ВСЕ контейнеры Ready
# При рестарте Pod'а перезапускаются ВСЕ контейнеры
```

---

## 🎯 **Резюме**

### **Pod ≠ Container**:
- **Pod** = группа из 1+ контейнеров
- **Container** = один Docker контейнер
- Pod'ы могут содержать:
  - 1 контейнер (большинство случаев)
  - 2+ контейнера (sidecar паттерн)
  - Init контейнеры (для инициализации)

### **Когда использовать multi-container Pod'ы**:
- ✅ Тесная связь между приложениями
- ✅ Нужны общие ресурсы (сеть, volumes)
- ✅ Sidecar, adapter, ambassador паттерны
- ❌ Независимые приложения (используйте разные Pod'ы)

### **Полезные команды для проверки**:
```bash
# Количество контейнеров
kubectl get pods -n <namespace>  # Смотрим READY: 3/3

# Список контейнеров
kubectl get pod <name> -n <ns> -o jsonpath='{.spec.containers[*].name}'

# Детали контейнеров
kubectl describe pod <name> -n <ns>

# Логи конкретного контейнера
kubectl logs <pod> -n <ns> -c <container>
```

---

**Теперь вы понимаете разницу между Pod'ами и контейнерами!** 🎓

*Используйте multi-container Pod'ы с умом - они мощный инструмент, но усложняют отладку.*

---

## 🔗 **Связанные документы**

### **Читать дальше**:
- [📖 Урок 1: Основы Kubernetes](learning-guide-01-basics.md) - теория Pod'ов и Deployments
- [📊 Prometheus Stack](prometheus-stack-components.md) - примеры multi-container Pod'ов
- [🔍 Проверка переменных окружения](how-to-check-env-variables.md) - практика с контейнерами

### **Навигация**:
- [📚 Полный индекс документации](INDEX.md)
- [🏠 Главная страница](../README.md)
