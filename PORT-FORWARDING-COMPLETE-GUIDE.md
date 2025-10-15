# 🔌 Полное руководство по пробросу портов - Kubernetes Learning Environment

## 📋 Обзор архитектуры

### **Проблема с Kind и NodePort:**
Kind кластер работает внутри Docker контейнера, поэтому NodePort сервисы не доступны напрямую с хоста. Решение - использование `kubectl port-forward`.

### **Архитектура доступа:**
```
Внешний пользователь → Хост (10.19.1.209) → Kind контейнер → Kubernetes Pod
```

---

## 🚀 Автоматический запуск всех сервисов

### **Один скрипт для всех сервисов:**
```bash
cd /root/kubernetes-learning
./scripts/start-learning-environment.sh
```

**Что делает скрипт:**
1. ✅ Проверяет доступность портов
2. ✅ Запускает port-forward для всех сервисов
3. ✅ Показывает все URL и логины
4. ✅ Предоставляет команды для остановки

---

## 🔧 Ручной запуск каждого сервиса

### **1. Kubernetes Dashboard**
```bash
# Запуск port-forward
kubectl port-forward -n kubernetes-dashboard svc/kubernetes-dashboard 30443:443 --address=0.0.0.0 &

# Проверка
curl -I https://10.19.1.209:30443 -k

# Доступ
URL: https://10.19.1.209:30443
Токен: [длительный токен на 1 год]
```

### **2. Grafana (Мониторинг)**
```bash
# Запуск port-forward
kubectl port-forward svc/grafana 30300:80 --address=0.0.0.0 &

# Проверка
curl -I http://10.19.1.209:30300

# Доступ
URL: http://10.19.1.209:30300
Логин: admin
Пароль: grafana123
```

### **3. ArgoCD (GitOps)**
```bash
# Запуск port-forward
kubectl port-forward -n argocd svc/argocd-server 30444:80 --address=0.0.0.0 &

# Проверка
curl -I http://10.19.1.209:30444

# Доступ
URL: http://10.19.1.209:30444
Логин: admin
Пароль: Q15LKJNm7K0WAFdw
```

### **4. Prometheus (Метрики)**
```bash
# Запуск port-forward
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 30090:9090 --address=0.0.0.0 &

# Проверка
curl -I http://10.19.1.209:30090

# Доступ
URL: http://10.19.1.209:30090
Логин: Не требуется (публичный доступ)
```

### **5. Alertmanager (Алерты)**
```bash
# Запуск port-forward
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-alertmanager 30093:9093 --address=0.0.0.0 &

# Проверка
curl -I http://10.19.1.209:30093

# Доступ
URL: http://10.19.1.209:30093
Логин: Не требуется (публичный доступ)
```

---

## 🔍 Детальное объяснение port-forward

### **Что такое kubectl port-forward:**
```bash
kubectl port-forward [TYPE/NAME] [LOCAL_PORT:]REMOTE_PORT
```

**Параметры:**
- `TYPE/NAME` - тип ресурса и его имя (например, `svc/grafana`)
- `LOCAL_PORT` - порт на локальной машине (например, `30300`)
- `REMOTE_PORT` - порт внутри Pod'а (например, `80`)
- `--address=0.0.0.0` - слушать на всех интерфейсах (не только localhost)

### **Пример разбора:**
```bash
kubectl port-forward -n argocd svc/argocd-server 30444:80 --address=0.0.0.0 &
```

**Разбор по частям:**
- `-n argocd` - namespace где находится сервис
- `svc/argocd-server` - тип `svc` (Service) с именем `argocd-server`
- `30444:80` - локальный порт 30444 → удаленный порт 80
- `--address=0.0.0.0` - слушать на всех IP адресах
- `&` - запуск в фоновом режиме

---

## 📊 Мониторинг port-forward процессов

### **Проверка активных port-forward:**
```bash
# Просмотр всех процессов kubectl port-forward
ps aux | grep "kubectl port-forward"

# Проверка портов
netstat -tlnp | grep -E "(30443|30300|30444|30090|30093)"

# Детальная информация о портах
ss -tlnp | grep -E "(30443|30300|30444|30090|30093)"
```

### **Остановка port-forward:**
```bash
# Остановка всех port-forward
pkill -f "kubectl port-forward"

# Остановка конкретного сервиса
pkill -f "kubectl port-forward.*grafana"

# Остановка через PID
kill [PID_ПРОЦЕССА]
```

---

## 🎯 Последовательное изучение Kubernetes

### **Этап 1: Основы (1-2 недели)**

#### **1.1 Kubernetes Dashboard**
- **Цель**: Понять структуру кластера
- **Что изучать**: Pod'ы, Deployment'ы, Service'ы, Namespace'ы
- **Практика**: Создание простых приложений

#### **1.2 Базовые команды kubectl**
```bash
# Основные команды
kubectl get pods --all-namespaces
kubectl describe pod [POD_NAME]
kubectl logs [POD_NAME]
kubectl exec -it [POD_NAME] -- /bin/bash
```

### **Этап 2: Сетевое взаимодействие (1 неделя)**

#### **2.1 Service и порты**
- **Цель**: Понять как работает сетевое взаимодействие
- **Что изучать**: ClusterIP, NodePort, LoadBalancer
- **Практика**: Настройка доступа к приложениям

#### **2.2 Port-forward**
- **Цель**: Научиться работать с port-forward
- **Что изучать**: kubectl port-forward, проброс портов
- **Практика**: Доступ к внутренним сервисам

### **Этап 3: Данные и хранилище (1-2 недели)**

#### **3.1 PostgreSQL**
- **Цель**: Работа с базами данных в Kubernetes
- **Что изучать**: PersistentVolume, ConfigMap, Secrets
- **Практика**: Создание приложений с БД

#### **3.2 Kafka**
- **Цель**: Потоковая обработка данных
- **Что изучать**: StatefulSet, топики, партиции
- **Практика**: Создание data pipeline

### **Этап 4: Мониторинг и наблюдение (1 неделя)**

#### **4.1 Grafana**
- **Цель**: Визуализация метрик
- **Что изучать**: Дашборды, алерты, источники данных
- **Практика**: Создание дашбордов

#### **4.2 Prometheus**
- **Цель**: Сбор и хранение метрик
- **Что изучать**: PromQL, ServiceMonitor, правила
- **Практика**: Настройка мониторинга

### **Этап 5: Автоматизация (1-2 недели)**

#### **5.1 ArgoCD**
- **Цель**: GitOps подход
- **Что изучать**: Application, Repository, синхронизация
- **Практика**: Автоматическое развертывание

#### **5.2 Helm**
- **Цель**: Управление приложениями
- **Что изучать**: Charts, values, релизы
- **Практика**: Упаковка приложений

---

## 📚 Структура документации для изучения

### **1. Начните с этих файлов:**
```
1. WEB-SERVICES-STATUS.md          # Текущий статус всех сервисов
2. COMPLETE-LEARNING-ENVIRONMENT.md # Общее руководство
3. PORT-FORWARDING-COMPLETE-GUIDE.md # Это руководство
```

### **2. Изучайте по этапам:**
```
Этап 1 - Основы:
├── Kubernetes Dashboard (веб-интерфейс)
├── kubectl команды
└── Pod'ы и Deployment'ы

Этап 2 - Сеть:
├── Service'ы
├── Port-forward
└── Ingress

Этап 3 - Данные:
├── POSTGRESQL-LEARNING-GUIDE.md
├── KAFKA-LEARNING-GUIDE.md
└── PersistentVolumes

Этап 4 - Мониторинг:
├── Grafana дашборды
├── Prometheus метрики
└── Алерты

Этап 5 - Автоматизация:
├── ARGOCD-GUIDE.md
├── Helm charts
└── CI/CD
```

---

## 🛠️ Troubleshooting

### **Частые проблемы:**

#### **1. Port-forward не работает**
```bash
# Проверка что Pod запущен
kubectl get pods -n [NAMESPACE]

# Проверка что Service существует
kubectl get svc -n [NAMESPACE]

# Проверка логов Pod'а
kubectl logs -n [NAMESPACE] [POD_NAME]
```

#### **2. Порт уже занят**
```bash
# Поиск процесса на порту
lsof -i :30300

# Остановка процесса
kill [PID]

# Или использование другого порта
kubectl port-forward svc/grafana 30301:80 --address=0.0.0.0 &
```

#### **3. Сервис недоступен**
```bash
# Проверка статуса Pod'а
kubectl describe pod -n [NAMESPACE] [POD_NAME]

# Проверка событий
kubectl get events -n [NAMESPACE] --sort-by=.metadata.creationTimestamp

# Проверка ресурсов
kubectl top pod -n [NAMESPACE]
```

---

## 🎯 Практические задания

### **Задание 1: Создание первого приложения**
1. Создайте Pod с Nginx
2. Создайте Service для Pod'а
3. Настройте port-forward для доступа
4. Проверьте доступность в браузере

### **Задание 2: Работа с базой данных**
1. Подключитесь к PostgreSQL
2. Создайте таблицу и данные
3. Настройте мониторинг в Grafana
4. Создайте дашборд для БД

### **Задание 3: Потоковая обработка**
1. Создайте топик в Kafka
2. Отправьте тестовые сообщения
3. Настройте потребителя
4. Интегрируйте с Grafana

### **Задание 4: GitOps автоматизация**
1. Создайте Git репозиторий с манифестами
2. Добавьте репозиторий в ArgoCD
3. Создайте Application
4. Настройте автоматическую синхронизацию

---

## 📖 Дополнительные ресурсы

### **Официальная документация:**
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [kubectl Reference](https://kubernetes.io/docs/reference/kubectl/)
- [Port Forwarding](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/)

### **Практические курсы:**
- [Kubernetes Basics](https://kubernetes.io/docs/tutorials/kubernetes-basics/)
- [CKA Preparation](https://github.com/dgkanatsios/CKAD-exercises)
- [Kubernetes by Example](https://kubernetesbyexample.com/)

---

**Создано**: $(date)
**Версия**: Kubernetes v1.27.3
**Статус**: Полное руководство готово! 🎉
