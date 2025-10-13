# 🌐 Диаграмма проброса портов

## 📊 **Визуализация цепочки проброса**

### **Grafana: http://10.19.1.209:3000**

```
┌─────────────────────────────────────────────────────────────────┐
│                         ВАШ БРАУЗЕР                             │
│                    http://10.19.1.209:3000                      │
└─────────────────────────────────────────────────────────────────┘
                                  │
                                  │ HTTP Request
                                  ↓
┌─────────────────────────────────────────────────────────────────┐
│                    ХОСТ (Сервер Debian)                         │
│                      IP: 10.19.1.209                            │
│                         Порт: 3000                              │
└─────────────────────────────────────────────────────────────────┘
                                  │
                                  │ Docker Port Mapping
                                  │ (kind-config.yaml)
                                  ↓
┌─────────────────────────────────────────────────────────────────┐
│              DOCKER CONTAINER (Kind Node)                       │
│          learning-cluster-control-plane                         │
│                    Порт: 30080                                  │
│                                                                 │
│  ┌────────────────────────────────────────────────────────┐    │
│  │         KUBERNETES CLUSTER (внутри контейнера)         │    │
│  │                                                        │    │
│  │  ┌──────────────────────────────────────────────┐     │    │
│  │  │     SERVICE: prometheus-grafana              │     │    │
│  │  │     Type: NodePort                           │     │    │
│  │  │     ClusterIP: 10.106.208.249                │     │    │
│  │  │     Port: 80 (ClusterIP)                     │     │    │
│  │  │     NodePort: 30080                          │     │    │
│  │  │     TargetPort: 3000                         │     │    │
│  │  └──────────────────────────────────────────────┘     │    │
│  │                         │                              │    │
│  │                         │ Selector:                    │    │
│  │                         │ app.kubernetes.io/name=grafana│   │
│  │                         ↓                              │    │
│  │  ┌──────────────────────────────────────────────┐     │    │
│  │  │     POD: prometheus-grafana-xxx              │     │    │
│  │  │     IP: 10.244.0.12                          │     │    │
│  │  │                                              │     │    │
│  │  │  ┌────────────────────────────────────┐     │     │    │
│  │  │  │  CONTAINER: grafana                │     │     │    │
│  │  │  │  Image: grafana/grafana:12.2.0     │     │     │    │
│  │  │  │  Port: 3000                        │     │     │    │
│  │  │  │  ┌──────────────────────────────┐  │     │     │    │
│  │  │  │  │   GRAFANA APPLICATION        │  │     │     │    │
│  │  │  │  │   Listening on: localhost:3000│ │     │     │    │
│  │  │  │  └──────────────────────────────┘  │     │     │    │
│  │  │  └────────────────────────────────────┘     │     │    │
│  │  └──────────────────────────────────────────────┘     │    │
│  └────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📋 **Таблица проброса всех сервисов**

| Сервис | Browser URL | Host Port | Docker Container Port | NodePort | Service ClusterIP | Pod Port | Container Port |
|--------|-------------|-----------|----------------------|----------|-------------------|----------|----------------|
| **Grafana** | http://10.19.1.209:3000 | 3000 | 30080 | 30080 | 10.106.208.249:80 | 10.244.0.12:3000 | 3000 |
| **Prometheus** | http://10.19.1.209:9090 | 9090 | 30090 | 30090 | 10.103.201.57:9090 | 10.244.0.X:9090 | 9090 |
| **Alertmanager** | http://10.19.1.209:9093 | 9093 | 30093 | 30093 | 10.109.218.53:9093 | 10.244.0.X:9093 | 9093 |
| **Ingress HTTP** | http://10.19.1.209:8080 | 8080 | 80 | - | - | - | 80 |
| **Ingress HTTPS** | https://10.19.1.209:8443 | 8443 | 443 | - | - | - | 443 |
| **K8s API** | - | - | 6443 | - | - | - | 6443 |

---

## 🔄 **Путь HTTP запроса (Grafana)**

### **Шаг за шагом**:

```
1. BROWSER
   └─→ http://10.19.1.209:3000
   
2. HOST (Debian Server)
   └─→ 0.0.0.0:3000 (слушает Docker)
   
3. DOCKER PORT MAPPING
   └─→ learning-cluster-control-plane:30080
       (настроено в kind-config.yaml)
   
4. KUBERNETES NODE
   └─→ iptables правила перенаправляют на ClusterIP
   
5. KUBERNETES SERVICE
   └─→ prometheus-grafana
       ClusterIP: 10.106.208.249:80
       (настроено в Helm values)
   
6. SERVICE SELECTOR
   └─→ Ищет Pod'ы с label: app.kubernetes.io/name=grafana
   
7. ENDPOINTS
   └─→ Pod IP: 10.244.0.12:3000
   
8. POD
   └─→ Перенаправляет на контейнер "grafana"
   
9. CONTAINER
   └─→ Grafana слушает на localhost:3000
   
10. GRAFANA APPLICATION
    └─→ Обрабатывает запрос и отвечает
    
11. RESPONSE
    └─→ Идет в обратном порядке до браузера
```

---

## 🔍 **Команды для проверки каждого уровня**

### **1. Docker уровень**:

```bash
# Проверить проброс портов
docker ps --filter "name=learning-cluster-control-plane" --format "table {{.Names}}\t{{.Ports}}"

# Результат:
# 0.0.0.0:3000->30080/tcp  ← Host:3000 → Container:30080
```

### **2. Kubernetes Service**:

```bash
# NodePort сервиса
kubectl get svc prometheus-grafana -n monitoring -o jsonpath='{.spec.ports[0].nodePort}'
# Результат: 30080

# ClusterIP сервиса
kubectl get svc prometheus-grafana -n monitoring -o jsonpath='{.spec.clusterIP}'
# Результат: 10.106.208.249
```

### **3. Endpoints (Pod IP)**:

```bash
# IP и порт Pod'а
kubectl get endpoints prometheus-grafana -n monitoring -o jsonpath='{.subsets[0].addresses[0].ip}:{.subsets[0].ports[0].port}'
# Результат: 10.244.0.12:3000
```

### **4. Container порт**:

```bash
# Порт контейнера
kubectl get pod -n monitoring -l app.kubernetes.io/name=grafana -o jsonpath='{.items[0].spec.containers[?(@.name=="grafana")].ports[0].containerPort}'
# Результат: 3000
```

---

## 💡 **Почему используются разные порты?**

### **Host Port (3000, 9090, 9093)**:
- **Причина**: Стандартные порты приложений
- **Удобство**: Привычные порты для пользователей
- **Kind позволяет**: Любые порты на хосте

### **NodePort (30080, 30090, 30093)**:
- **Причина**: Kubernetes ограничение 30000-32767
- **Логика**: 30000 + стандартный порт приложения
- **Пример**: 30000 + 80 (HTTP) = 30080

### **Container Port (3000, 9090, 9093)**:
- **Причина**: Стандарты приложений
- **Grafana**: Всегда слушает на 3000
- **Prometheus**: Всегда слушает на 9090

---

## 📝 **Конфигурационные файлы**

### **1. Kind Config** (`kind-config.yaml`):

```yaml
extraPortMappings:
- containerPort: 30080  # NodePort внутри Kind
  hostPort: 3000        # Порт на хосте (Debian)
  protocol: TCP
```

### **2. Helm Values** (`helm-values/custom-prometheus-values.yaml`):

```yaml
grafana:
  service:
    type: NodePort
    nodePort: 30080  # Указываем конкретный NodePort
```

### **3. Результат в Kubernetes**:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: prometheus-grafana
  namespace: monitoring
spec:
  type: NodePort
  ports:
  - port: 80          # ClusterIP порт
    targetPort: 3000  # Порт контейнера
    nodePort: 30080   # NodePort
  selector:
    app.kubernetes.io/name: grafana
```

---

## 🎯 **Практическое задание**

### **Проверить всю цепочку**:

```bash
# 1. Docker проброс
docker port learning-cluster-control-plane 30080
# Результат: 0.0.0.0:3000

# 2. Kubernetes Service
kubectl get svc prometheus-grafana -n monitoring -o wide
# Смотрим: TYPE=NodePort, PORT(S)=80:30080/TCP

# 3. Endpoints (Pod IP)
kubectl get endpoints prometheus-grafana -n monitoring
# Смотрим: ENDPOINTS=10.244.0.12:3000

# 4. Тест изнутри Pod'а
kubectl exec -n monitoring deployment/prometheus-grafana -c grafana -- curl -s http://localhost:3000/api/health
# Результат: {"database":"ok","version":"12.2.0"}

# 5. Тест через Service
kubectl run curl-test --image=curlimages/curl -i --rm --restart=Never -- curl -s http://prometheus-grafana.monitoring.svc.cluster.local/api/health
# Результат: {"database":"ok","version":"12.2.0"}

# 6. Тест с хоста
curl -s http://10.19.1.209:3000/api/health
# Результат: {"database":"ok","version":"12.2.0"}
```

---

## 🚀 **Итоги**

### **3 уровня проброса**:

1. **Docker**: Host:3000 → Container:30080
   - Настроено в `kind-config.yaml`
   - Работает как `docker run -p 3000:30080`

2. **Kubernetes NodePort**: Node:30080 → ClusterIP:80
   - Настроено в Helm values
   - Автоматически создается Kubernetes

3. **Kubernetes Service**: ClusterIP:80 → Pod:3000
   - Настроено в Service manifest
   - Использует selector для поиска Pod'ов

### **Ключевые файлы**:
- `kind-config.yaml` - Docker проброс
- `helm-values/custom-prometheus-values.yaml` - NodePort
- Service manifest (создается Helm) - ClusterIP

### **Порты**:
- **3000** - Host & Container (стандарт Grafana)
- **30080** - NodePort (30000 + 80)
- **80** - Service ClusterIP (стандарт HTTP)

**Теперь вы понимаете всю цепочку!** 🎓
