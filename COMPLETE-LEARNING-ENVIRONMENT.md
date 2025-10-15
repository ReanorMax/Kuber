# 🎓 Полная обучающая среда Kubernetes

## 📋 Обзор установленных сервисов

### **Управление кластером:**
- ✅ **Kubernetes Dashboard** - веб-интерфейс для управления
- ✅ **ArgoCD** - GitOps автоматизация
- ✅ **Weave Scope** - визуализация топологии

### **Данные и очереди:**
- ✅ **PostgreSQL** - реляционная база данных
- ✅ **Kafka** - потоковая платформа данных

### **Мониторинг:**
- ✅ **Grafana** - дашборды и визуализация
- ✅ **Prometheus** - сбор метрик (уже был установлен)

### **Автоматизация:**
- ⏸️ **AWX** - Ansible автоматизация (остановлен)

---

## 🚀 Быстрый запуск

### **Автоматический запуск всех сервисов:**
```bash
cd /root/kubernetes-learning
./scripts/start-learning-environment.sh
```

### **Ручной запуск ArgoCD (если нужен только он):**
```bash
kubectl port-forward -n argocd svc/argocd-server 30444:80 --address=0.0.0.0 &
```

---

## 🌐 Доступ к сервисам

### **1. Kubernetes Dashboard**
```
URL:   https://10.19.1.209:30443
Токен: eyJhbGciOiJSUzI1NiIsImtpZCI6ImEyTVhPZ0pQdFBEeDZXZGxWREgySWpILXRMTXU3bnFSQzgxMFNGSHhHZmMifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiXSwiZXhwIjoxNzkxOTk1NzE4LCJpYXQiOjE3NjA0NTk3MTgsImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsInNlcnZpY2VhY2NvdW50Ijp7Im5hbWUiOiJkYXNoYm9hcmQtYWRtaW4iLCJ1aWQiOiI4YjUxMzY0Mi0yMGJiLTRjM2YtOTRjOC0xZmRjYTUxNzE0NGYifX0sIm5iZiI6MTc2MDQ1OTcxOCwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50Omt1YmVybmV0ZXMtZGFzaGJvYXJkOmRhc2hib2FyZC1hZG1pbiJ9.FL6GQ1ed18YfviS5HupH0vmcZUICgb0rrcRAE0lAGQRY_KvekGeA0iP2LzyrqdsdKJ2q8TNE3MXrmhHBTO6_e3J0YZoIXmvCXxNeG0AB4iu6orkFQJDHAPJAv_5xWUOwLjViZgJc5YbNicmy_E0mW-VtHXAPm0VKHFsmiqFc6rpqKMnikpMgDNV716rqMeTyHswZwfvVFRjeNTJVsjlC74-TyY-WeqgNyop7ri-UX54tqAVVPA0wvjul4q3u5c2TDr6xxxbqhpSgnAMvOZcyPLR_AkxVyOqXlJTaHxRSu8eAw6ODQ4fiOyMqzC96RrIrRoHPCjOoR5HQoC2w5ztVug
Срок действия: 1 год (до 2026-10-14)
```

### **2. ArgoCD (GitOps)**
```
URL:   http://10.19.1.209:30444
Логин: admin
Пароль: Q15LKJNm7K0WAFdw

⚠️  ВАЖНО: Требует запуска port-forward!
Команда: kubectl port-forward -n argocd svc/argocd-server 30444:80 --address=0.0.0.0 &
Или используйте: ./scripts/start-learning-environment.sh
```

### **3. Grafana (Мониторинг)**
```
URL:   http://10.19.1.209:30300
Логин: admin
Пароль: grafana123
```

### **4. PostgreSQL (База данных)**
```
Host: 10.19.1.209
Port: 30432
Database: learningdb
Username: admin
Password: admin123
```

### **5. Kafka (Потоковые данные)**
```
Bootstrap Server: kafka.kafka.svc.cluster.local:9092
Namespace: kafka
```

---

## 🎯 Задачи для обучения

### **Уровень 1: Основы Kubernetes**

#### **Задача 1.1: Изучение Pod'ов**
1. Создайте простой Pod с Nginx
2. Проверьте логи Pod'а
3. Выполните команды внутри Pod'а
4. Удалите Pod

**Команды:**
```bash
# Создание Pod
kubectl run nginx-pod --image=nginx --port=80

# Проверка статуса
kubectl get pods

# Логи
kubectl logs nginx-pod

# Выполнение команд
kubectl exec -it nginx-pod -- /bin/bash

# Удаление
kubectl delete pod nginx-pod
```

#### **Задача 1.2: Deployment и масштабирование**
1. Создайте Deployment с 3 репликами
2. Масштабируйте до 5 реплик
3. Проверьте историю изменений
4. Откатите к предыдущей версии

**Команды:**
```bash
# Создание Deployment
kubectl create deployment nginx-deploy --image=nginx --replicas=3

# Масштабирование
kubectl scale deployment nginx-deploy --replicas=5

# История
kubectl rollout history deployment/nginx-deploy

# Откат
kubectl rollout undo deployment/nginx-deploy
```

### **Уровень 2: Сервисы и сетевое взаимодействие**

#### **Задача 2.1: Создание Service**
1. Создайте Service для вашего Deployment
2. Проверьте доступность через Service
3. Создайте NodePort для внешнего доступа

**Команды:**
```bash
# Создание Service
kubectl expose deployment nginx-deploy --port=80 --type=ClusterIP

# Проверка
kubectl get svc

# NodePort
kubectl expose deployment nginx-deploy --port=80 --type=NodePort
```

#### **Задача 2.2: ConfigMap и Secrets**
1. Создайте ConfigMap с конфигурацией
2. Создайте Secret с паролем
3. Подключите их к Pod'у

**Команды:**
```bash
# ConfigMap
kubectl create configmap app-config --from-literal=database_url=postgres://localhost:5432/mydb

# Secret
kubectl create secret generic app-secret --from-literal=password=secret123

# Использование в Pod
kubectl create -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  containers:
  - name: test-container
    image: nginx
    envFrom:
    - configMapRef:
        name: app-config
    - secretRef:
        name: app-secret
EOF
```

### **Уровень 3: Работа с данными**

#### **Задача 3.1: PostgreSQL**
1. Подключитесь к PostgreSQL
2. Создайте базу данных и таблицу
3. Добавьте данные
4. Создайте бэкап

**Команды:**
```bash
# Подключение к PostgreSQL
kubectl exec -it -n postgresql deployment/postgres -- psql -U admin -d learningdb

# В psql:
CREATE TABLE users (id SERIAL PRIMARY KEY, name VARCHAR(100), email VARCHAR(100));
INSERT INTO users (name, email) VALUES ('John Doe', 'john@example.com');
SELECT * FROM users;
```

#### **Задача 3.2: Kafka**
1. Создайте топик в Kafka
2. Отправьте сообщения
3. Прочитайте сообщения
4. Мониторьте топики

**Команды:**
```bash
# Создание топика
kubectl exec -it -n kafka deployment/kafka -- kafka-topics --create --topic learning-topic --bootstrap-server localhost:9092

# Отправка сообщений
kubectl exec -it -n kafka deployment/kafka -- kafka-console-producer --topic learning-topic --bootstrap-server localhost:9092

# Чтение сообщений
kubectl exec -it -n kafka deployment/kafka -- kafka-console-consumer --topic learning-topic --bootstrap-server localhost:9092 --from-beginning
```

### **Уровень 4: Мониторинг и наблюдение**

#### **Задача 4.1: Grafana Dashboard**
1. Войдите в Grafana
2. Создайте дашборд для мониторинга Pod'ов
3. Настройте алерты
4. Добавьте метрики PostgreSQL

#### **Задача 4.2: Логи и отладка**
1. Используйте `kubectl logs` для просмотра логов
2. Настройте централизованный сбор логов
3. Создайте дашборд для логов в Grafana

### **Уровень 5: GitOps с ArgoCD**

#### **Задача 5.1: Первое приложение**
1. Создайте Git репозиторий с Kubernetes манифестами
2. Добавьте репозиторий в ArgoCD
3. Создайте Application
4. Настройте автоматическую синхронизацию

#### **Задача 5.2: CI/CD Pipeline**
1. Создайте простой CI/CD pipeline
2. Автоматизируйте развертывание
3. Настройте уведомления

---

## 🔧 Полезные команды

### **Общие команды:**
```bash
# Статус всех ресурсов
kubectl get all --all-namespaces

# Описание ресурса
kubectl describe pod <pod-name>

# Редактирование ресурса
kubectl edit deployment <deployment-name>

# Просмотр событий
kubectl get events --sort-by=.metadata.creationTimestamp
```

### **Отладка:**
```bash
# Логи Pod'а
kubectl logs <pod-name> -f

# Выполнение команд в Pod'е
kubectl exec -it <pod-name> -- /bin/bash

# Порт-форвардинг
kubectl port-forward svc/<service-name> 8080:80
```

### **Мониторинг:**
```bash
# Использование ресурсов
kubectl top nodes
kubectl top pods

# Статус кластера
kubectl cluster-info
kubectl get componentstatuses
```

---

## 📊 Дашборды Grafana

### **Предустановленные дашборды:**
1. **Kubernetes Cluster** - общий обзор кластера
2. **Node Exporter** - метрики узлов
3. **Pod Metrics** - метрики Pod'ов
4. **PostgreSQL** - метрики базы данных

### **Создание собственных дашбордов:**
1. Перейдите в Grafana → Dashboards → New
2. Добавьте панели с метриками
3. Настройте алерты
4. Сохраните дашборд

---

## 🚀 Следующие шаги

### **Для углубленного изучения:**
1. **Helm Charts** - управление приложениями
2. **Operators** - автоматизация операций
3. **Service Mesh** - Istio или Linkerd
4. **Security** - RBAC, Network Policies
5. **Storage** - PersistentVolumes, StorageClasses

### **Практические проекты:**
1. **Микросервисная архитектура** - развертывание нескольких сервисов
2. **CI/CD Pipeline** - автоматизация развертывания
3. **Мониторинг стэк** - Prometheus + Grafana + AlertManager
4. **Балансировка нагрузки** - Ingress Controllers
5. **Безопасность** - Pod Security Standards

---

## 📚 Дополнительные ресурсы

### **Документация:**
- [Kubernetes Official Docs](https://kubernetes.io/docs/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Grafana Documentation](https://grafana.com/docs/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)

### **Онлайн курсы:**
- Kubernetes Fundamentals
- CKA (Certified Kubernetes Administrator)
- CKAD (Certified Kubernetes Application Developer)

---

**Создано**: $(date)
**Версия**: Kubernetes v1.27.3, ArgoCD v3.1.8, Grafana latest
**Статус**: Готово к обучению! 🎉

