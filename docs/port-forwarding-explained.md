# 🌐 Проброс портов в Kubernetes - Полное объяснение

> 📚 **Навигация**: [← Назад к INDEX](INDEX.md) | [🏠 Главная](../README.md)


## 🔍 **Как работает проброс портов?**

### **3 уровня проброса**:

```
Ваш браузер → Хост (сервер) → Docker контейнер (Kind) → Kubernetes Service → Pod → Container
```

Давайте разберем каждый уровень!

---

## 📊 **Уровень 1: Kind Config (Docker → Host)**

### **Файл**: `kind-config.yaml`

```yaml
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30080  # Порт ВНУТРИ Docker контейнера Kind
    hostPort: 3000        # Порт на ХОСТЕ (сервере 10.19.1.209)
    protocol: TCP
  
  - containerPort: 30090  # Prometheus внутри контейнера
    hostPort: 9090        # Prometheus на хосте
    protocol: TCP
  
  - containerPort: 30093  # Alertmanager внутри контейнера
    hostPort: 9093        # Alertmanager на хосте
    protocol: TCP
```

### **Что происходит?**

1. **Kind создает Docker контейнер** с именем `learning-cluster-control-plane`
2. **Docker пробрасывает порты** из контейнера на хост
3. **Результат**: 
   - `10.19.1.209:3000` → `learning-cluster-control-plane:30080`
   - `10.19.1.209:9090` → `learning-cluster-control-plane:30090`
   - `10.19.1.209:9093` → `learning-cluster-control-plane:30093`

### **Проверка на Docker уровне**:

```bash
docker ps --filter "name=learning-cluster-control-plane" --format "table {{.Names}}\t{{.Ports}}"
```

**Результат**:
```
NAMES                            PORTS
learning-cluster-control-plane   0.0.0.0:3000->30080/tcp    ← Grafana
                                 0.0.0.0:9090->30090/tcp    ← Prometheus
                                 0.0.0.0:9093->30093/tcp    ← Alertmanager
                                 0.0.0.0:8080->80/tcp       ← Ingress HTTP
                                 0.0.0.0:8443->443/tcp      ← Ingress HTTPS
                                 127.0.0.1:41917->6443/tcp  ← Kubernetes API
```

**Объяснение**:
- `0.0.0.0:3000` - доступен с любого IP хоста
- `->30080/tcp` - пробрасывается на порт 30080 внутри контейнера
- `127.0.0.1:41917` - доступен только с localhost (безопасность!)

---

## 📊 **Уровень 2: Kubernetes NodePort (Service → Node)**

### **Kubernetes Services**:

```bash
kubectl get svc -n monitoring -o wide
```

**Результат**:
```
NAME                                      TYPE        PORT(S)              
prometheus-grafana                        NodePort    80:30080/TCP         ← Важно!
prometheus-kube-prometheus-prometheus     NodePort    9090:30090/TCP       ← Важно!
prometheus-kube-prometheus-alertmanager   NodePort    9093:30093/TCP       ← Важно!
```

### **Формат NodePort**: `<ClusterIP Port>:<NodePort>/TCP`

**Пример Grafana**: `80:30080/TCP`
- **80** - порт внутри кластера (ClusterIP)
- **30080** - порт на каждой ноде кластера (NodePort)

### **Что происходит?**

1. **Service создает NodePort** на каждой ноде кластера
2. **Kind нода** (Docker контейнер) слушает на порту 30080
3. **Трафик на 30080** перенаправляется на ClusterIP:80
4. **ClusterIP:80** перенаправляется на Pod

### **Проверка NodePort**:

```bash
# Получить NodePort для Grafana
kubectl get svc prometheus-grafana -n monitoring -o jsonpath='{.spec.ports[0].nodePort}'
# Результат: 30080
```

### **Почему именно 30080, 30090, 30093?**

```yaml
# В Helm values мы указали:
grafana:
  service:
    type: NodePort
    nodePort: 30080  # ← Вот откуда!

prometheus:
  service:
    type: NodePort
    nodePort: 30090  # ← Вот откуда!

alertmanager:
  service:
    type: NodePort
    nodePort: 30093  # ← Вот откуда!
```

**Диапазон NodePort**: 30000-32767 (по умолчанию в Kubernetes)

---

## 📊 **Уровень 3: Kubernetes Service (Pod → Service)**

### **Service перенаправляет трафик на Pod**:

```bash
# Получить endpoints (Pod'ы) для Grafana
kubectl get endpoints prometheus-grafana -n monitoring
```

**Результат**:
```
NAME                 ENDPOINTS          AGE
prometheus-grafana   10.244.0.12:3000   3h
                     ^^^^^^^^^^^
                     IP Pod'а и порт контейнера
```

### **Что происходит?**

1. **Service получает трафик** на ClusterIP:80
2. **Ищет Pod'ы** по selector'у: `app.kubernetes.io/name=grafana`
3. **Перенаправляет трафик** на Pod IP:3000 (порт контейнера)
4. **Контейнер Grafana** слушает на порту 3000

### **Проверка selector'а**:

```bash
# Service selector
kubectl get svc prometheus-grafana -n monitoring -o jsonpath='{.spec.selector}'
# {"app.kubernetes.io/instance":"prometheus","app.kubernetes.io/name":"grafana"}

# Pod'ы с такими labels
kubectl get pods -n monitoring -l app.kubernetes.io/name=grafana
# prometheus-grafana-xxx
```

---

## 🔄 **Полная цепочка проброса (на примере Grafana)**

### **Запрос**: http://10.19.1.209:3000

```
1. Браузер → 10.19.1.209:3000 (IP хоста, порт 3000)
   ↓
2. Docker проброс → learning-cluster-control-plane:30080 (контейнер Kind)
   ↓
3. Kubernetes NodePort → ClusterIP 10.106.208.249:80 (Service)
   ↓
4. Service selector → Pod 10.244.0.12:3000 (IP Pod'а)
   ↓
5. Pod → Container "grafana" порт 3000
   ↓
6. Grafana отвечает → цепочка в обратном порядке → браузер
```

### **В цифрах**:

| Уровень | Адрес | Описание |
|---------|-------|----------|
| **Хост** | `10.19.1.209:3000` | Внешний IP сервера |
| **Docker** | `learning-cluster-control-plane:30080` | Порт NodePort в Kind |
| **Service** | `10.106.208.249:80` | ClusterIP (внутри кластера) |
| **Pod** | `10.244.0.12:3000` | IP Pod'а Grafana |
| **Container** | `localhost:3000` | Grafana слушает на 3000 |

---

## 🔧 **Почему используются именно эти порты?**

### **1. NodePort диапазон: 30000-32767**

**Почему не 3000?**
- Kubernetes резервирует диапазон 30000-32767 для NodePort
- Порты < 30000 зарезервированы для системных сервисов
- Это предотвращает конфликты с другими приложениями на ноде

**Наши выборы**:
- **30080** - Grafana (30000 + 80, где 80 стандартный HTTP)
- **30090** - Prometheus (30000 + 90, округление от 9090)
- **30093** - Alertmanager (30000 + 93, округление от 9093)

### **2. HostPort в Kind: любые порты**

**Почему 3000, 9090, 9093?**
- Это **стандартные порты** для этих приложений
- **Grafana** традиционно использует 3000
- **Prometheus** традиционно использует 9090
- **Alertmanager** традиционно использует 9093

**Kind может пробросить любой порт**, потому что:
- Это Docker проброс, не Kubernetes
- Нет ограничений на диапазон
- Работает как `docker run -p 3000:30080`

### **3. Container порты: стандарты приложений**

| Приложение | Порт | Почему? |
|------------|------|---------|
| Grafana | 3000 | Стандарт Grafana |
| Prometheus | 9090 | Стандарт Prometheus |
| Alertmanager | 9093 | Стандарт Alertmanager |
| Kubernetes API | 6443 | Стандарт Kubernetes |
| Nginx (HTTP) | 80 | Стандарт HTTP |
| Nginx (HTTPS) | 443 | Стандарт HTTPS |

---

## 📝 **Где настроены порты?**

### **1. Kind Config** (`kind-config.yaml`):

```yaml
extraPortMappings:
- containerPort: 30080  # NodePort Grafana
  hostPort: 3000        # Хост порт
```

**Кто создал?** Мы, при создании Kind кластера

### **2. Helm Values** (`helm-values/custom-prometheus-values.yaml`):

```yaml
grafana:
  service:
    type: NodePort
    nodePort: 30080  # ← Указываем конкретный NodePort
```

**Кто создал?** Мы, при установке Prometheus stack

### **3. Kubernetes Service**:

```bash
kubectl get svc prometheus-grafana -n monitoring -o yaml
```

```yaml
spec:
  type: NodePort
  ports:
  - port: 80          # ClusterIP порт
    targetPort: 3000  # Порт контейнера
    nodePort: 30080   # NodePort
```

**Кто создал?** Helm, на основе values

### **4. Deployment (Container)**:

```bash
kubectl get deployment prometheus-grafana -n monitoring -o yaml
```

```yaml
spec:
  containers:
  - name: grafana
    image: grafana/grafana:12.2.0
    ports:
    - containerPort: 3000  # Grafana слушает на 3000
```

**Кто создал?** Helm chart Grafana

---

## 🔍 **Как проверить всю цепочку?**

### **1. Docker уровень**:

```bash
# Проверить проброс Docker → Host
docker ps --filter "name=learning-cluster-control-plane" --format "table {{.Names}}\t{{.Ports}}"

# Результат:
# 0.0.0.0:3000->30080/tcp  ← Host:3000 → Container:30080
```

### **2. Kubernetes NodePort**:

```bash
# Проверить Service NodePort
kubectl get svc -n monitoring -o custom-columns=NAME:.metadata.name,TYPE:.spec.type,PORTS:.spec.ports[*].nodePort

# Результат:
# NAME                   TYPE       PORTS
# prometheus-grafana     NodePort   30080  ← NodePort
```

### **3. Service Endpoints**:

```bash
# Проверить Pod IP и порт
kubectl get endpoints prometheus-grafana -n monitoring

# Результат:
# ENDPOINTS
# 10.244.0.12:3000  ← Pod IP:Container Port
```

### **4. Pod Container**:

```bash
# Проверить порт контейнера
kubectl get pod -n monitoring -l app.kubernetes.io/name=grafana -o jsonpath='{.items[0].spec.containers[?(@.name=="grafana")].ports[0].containerPort}'

# Результат:
# 3000  ← Container порт
```

### **5. Полная проверка доступности**:

```bash
# Шаг 1: Проверка изнутри Pod'а
kubectl exec -n monitoring deployment/prometheus-grafana -c grafana -- curl -s http://localhost:3000/api/health

# Шаг 2: Проверка через Service (ClusterIP)
kubectl run curl-test --image=curlimages/curl -i --rm --restart=Never -- curl -s http://prometheus-grafana.monitoring.svc.cluster.local/api/health

# Шаг 3: Проверка через NodePort (изнутри Kind)
docker exec learning-cluster-control-plane curl -s http://localhost:30080/api/health

# Шаг 4: Проверка с хоста
curl -s http://10.19.1.209:3000/api/health

# Шаг 5: Проверка из браузера
# http://10.19.1.209:3000
```

---

## 💡 **Типы проброса портов в Kubernetes**

### **1. NodePort** (используем мы):

**Преимущества**:
- ✅ Простой внешний доступ
- ✅ Работает на всех нодах
- ✅ Не нужен LoadBalancer

**Недостатки**:
- ❌ Порты только 30000-32767
- ❌ Один порт = один сервис
- ❌ Нет SSL termination

**Когда использовать**:
- Локальные кластеры (Kind, Minikube)
- Тестирование
- Простой доступ без LoadBalancer

### **2. LoadBalancer**:

**Преимущества**:
- ✅ Автоматический внешний IP
- ✅ Любые порты
- ✅ Балансировка нагрузки

**Недостатки**:
- ❌ Требует облачный провайдер (AWS, GCP, Azure)
- ❌ Стоит денег
- ❌ Не работает в Kind/Minikube

**Когда использовать**:
- Production в облаке
- Нужен внешний IP
- Высокая доступность

### **3. Ingress** (тоже настроили):

**Преимущества**:
- ✅ HTTP/HTTPS роутинг
- ✅ SSL termination
- ✅ Один IP для многих сервисов
- ✅ Path-based роутинг

**Недостатки**:
- ❌ Только HTTP/HTTPS
- ❌ Нужен Ingress Controller
- ❌ Сложнее настройка

**Когда использовать**:
- Production HTTP сервисы
- Нужен SSL/TLS
- Множество сервисов на одном IP

### **4. kubectl port-forward** (временный):

**Преимущества**:
- ✅ Быстрый доступ для отладки
- ✅ Безопасный туннель
- ✅ Любые порты

**Недостатки**:
- ❌ Только пока команда запущена
- ❌ Один клиент
- ❌ Не для production

**Когда использовать**:
- Отладка
- Временный доступ
- Локальная разработка

---

## 🎯 **Резюме**

### **Наша цепочка проброса**:

```
Browser (10.19.1.209:3000)
    ↓ Docker проброс
Kind Container (:30080)
    ↓ Kubernetes NodePort
Service ClusterIP (:80)
    ↓ Selector + Endpoints
Pod (:3000)
    ↓ Container
Grafana (localhost:3000)
```

### **Почему эти порты?**

| Порт | Уровень | Почему? |
|------|---------|---------|
| 3000 | Host | Стандартный порт Grafana |
| 30080 | NodePort | 30000 + 80 (HTTP) |
| 80 | Service | Стандартный HTTP |
| 3000 | Container | Стандартный порт Grafana |

### **Где настроено?**

1. **Kind Config** → Docker проброс (Host → Container)
2. **Helm Values** → NodePort (Node → Service)
3. **Service Manifest** → ClusterIP (Service → Pod)
4. **Deployment** → Container порт (Pod → App)

### **Как проверить?**

```bash
# Docker
docker ps --filter "name=learning-cluster" --format "{{.Ports}}"

# Kubernetes
kubectl get svc -n monitoring
kubectl get endpoints -n monitoring
kubectl describe pod -n monitoring <pod-name>

# Тестирование
curl http://10.19.1.209:3000/api/health
```

---

**Теперь вы понимаете всю цепочку проброса портов!** 🎓

*Kubernetes networking - это луковица из нескольких уровней. Каждый уровень имеет свою роль в доставке трафика от клиента к приложению.*

---

## 🔗 **Связанные документы**

### **Читать вместе**:
- [📊 Визуальная диаграмма проброса](port-mapping-diagram.md) - схемы и таблицы
- [📖 Урок 2: Сети и мониторинг](learning-guide-02-networking-monitoring.md) - теория сетей Kubernetes
- [⚙️ Настройка Kind](kind-infrastructure-setup-guide.md) - где настроены порты

### **Навигация**:
- [📚 Полный индекс документации](INDEX.md)
- [🏠 Главная страница](../README.md)
