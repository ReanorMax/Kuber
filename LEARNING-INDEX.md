# 📚 Индекс обучения Kubernetes - Полное руководство

## 🎯 **Начните здесь!**

### **🚀 Быстрый старт (5 минут)**
1. **Запустите все сервисы**: `./scripts/start-learning-environment.sh`
2. **Проверьте доступность**: [WEB-SERVICES-STATUS.md](./WEB-SERVICES-STATUS.md)
3. **Изучите проброс портов**: [PORT-FORWARDING-COMPLETE-GUIDE.md](./PORT-FORWARDING-COMPLETE-GUIDE.md)

---

## 📖 **Основные руководства**

### **🔧 Управление кластером**
- **[WEB-SERVICES-STATUS.md](./WEB-SERVICES-STATUS.md)** - Текущий статус всех веб-сервисов
- **[PORT-FORWARDING-COMPLETE-GUIDE.md](./PORT-FORWARDING-COMPLETE-GUIDE.md)** - Полное руководство по пробросу портов
- **[COMPLETE-LEARNING-ENVIRONMENT.md](./COMPLETE-LEARNING-ENVIRONMENT.md)** - Общее руководство по среде обучения

### **🗄️ Работа с данными**
- **[POSTGRESQL-LEARNING-GUIDE.md](./POSTGRESQL-LEARNING-GUIDE.md)** - Подробный гайд по PostgreSQL
- **[KAFKA-LEARNING-GUIDE.md](./KAFKA-LEARNING-GUIDE.md)** - Подробный гайд по Kafka

### **🚀 Автоматизация**
- **[ARGOCD-GUIDE.md](./ARGOCD-GUIDE.md)** - GitOps с ArgoCD

---

## 🎓 **Поэтапное изучение**

### **Этап 1: Основы Kubernetes (1-2 недели)**

#### **День 1-3: Первое знакомство**
1. **Kubernetes Dashboard**
   - URL: https://10.19.1.209:30443
   - Изучите: Pod'ы, Deployment'ы, Service'ы
   - Практика: Создайте простой Pod с Nginx

2. **Базовые команды kubectl**
   ```bash
   kubectl get pods --all-namespaces
   kubectl describe pod [POD_NAME]
   kubectl logs [POD_NAME]
   kubectl exec -it [POD_NAME] -- /bin/bash
   ```

#### **День 4-7: Сетевое взаимодействие**
1. **Service и порты**
   - ClusterIP, NodePort, LoadBalancer
   - Port-forward для доступа к сервисам

2. **Практические задания**
   - Создайте Service для вашего Pod'а
   - Настройте port-forward
   - Проверьте доступность в браузере

### **Этап 2: Данные и хранилище (1-2 недели)**

#### **Неделя 1: PostgreSQL**
1. **Изучение**: [POSTGRESQL-LEARNING-GUIDE.md](./POSTGRESQL-LEARNING-GUIDE.md)
2. **Практика**:
   - Подключение к PostgreSQL
   - Создание таблиц и данных
   - Настройка мониторинга

#### **Неделя 2: Kafka**
1. **Изучение**: [KAFKA-LEARNING-GUIDE.md](./KAFKA-LEARNING-GUIDE.md)
2. **Практика**:
   - Создание топиков
   - Отправка и получение сообщений
   - Настройка потоковой обработки

### **Этап 3: Мониторинг и наблюдение (1 неделя)**

#### **День 1-3: Grafana**
1. **URL**: http://10.19.1.209:30300
2. **Изучение**:
   - Создание дашбордов
   - Настройка источников данных
   - Создание алертов

#### **День 4-7: Prometheus**
1. **URL**: http://10.19.1.209:30090
2. **Изучение**:
   - PromQL запросы
   - ServiceMonitor
   - Правила алертов

### **Этап 4: Автоматизация (1-2 недели)**

#### **Неделя 1: ArgoCD**
1. **Изучение**: [ARGOCD-GUIDE.md](./ARGOCD-GUIDE.md)
2. **Практика**:
   - Создание Git репозитория
   - Настройка ArgoCD Application
   - Автоматическая синхронизация

#### **Неделя 2: Helm**
1. **Изучение**: Helm charts и values
2. **Практика**:
   - Создание собственного chart'а
   - Управление релизами

---

## 🌐 **Доступ к сервисам**

### **🔧 Kubernetes Dashboard**
```
URL:   https://10.19.1.209:30443
Токен: [длительный токен на 1 год]
Цель:  Управление кластером, изучение ресурсов
```

### **📊 Grafana**
```
URL:   http://10.19.1.209:30300
Логин: admin
Пароль: grafana123
Цель:  Мониторинг, дашборды, алерты
```

### **🚀 ArgoCD**
```
URL:   http://10.19.1.209:30444
Логин: admin
Пароль: Q15LKJNm7K0WAFdw
Цель:  GitOps автоматизация
```

### **📈 Prometheus**
```
URL:   http://10.19.1.209:30090
Логин: Не требуется
Цель:  Сбор и хранение метрик
```

### **🚨 Alertmanager**
```
URL:   http://10.19.1.209:30093
Логин: Не требуется
Цель:  Управление алертами
```

### **🗄️ PostgreSQL**
```
Host: 10.19.1.209
Port: 30432
Database: learningdb
Username: admin
Password: admin123
Цель:  База данных, изучение PersistentVolumes
```

### **🚀 Kafka**
```
Bootstrap Server: kafka.kafka.svc.cluster.local:9092
Namespace: kafka
Цель:  Потоковая обработка данных
```

---

## 🛠️ **Полезные команды**

### **Запуск всех сервисов:**
```bash
cd /root/kubernetes-learning
./scripts/start-learning-environment.sh
```

### **Проверка статуса:**
```bash
# Все Pod'ы
kubectl get pods --all-namespaces

# Port-forward процессы
ps aux | grep "kubectl port-forward"

# Открытые порты
netstat -tlnp | grep -E "(30443|30300|30444|30090|30093)"
```

### **Остановка сервисов:**
```bash
# Остановка port-forward
pkill -f "kubectl port-forward"

# Остановка конкретного сервиса
kubectl scale deployment [DEPLOYMENT_NAME] --replicas=0
```

---

## 🎯 **Практические проекты**

### **Проект 1: Веб-приложение с БД**
1. Создайте Pod с веб-приложением
2. Подключите PostgreSQL
3. Настройте мониторинг в Grafana
4. Создайте дашборд для приложения

### **Проект 2: Data Pipeline**
1. Создайте Producer для Kafka
2. Создайте Consumer для обработки данных
3. Сохраните результаты в PostgreSQL
4. Настройте мониторинг всего pipeline'а

### **Проект 3: GitOps развертывание**
1. Создайте Git репозиторий с манифестами
2. Настройте ArgoCD Application
3. Настройте автоматическую синхронизацию
4. Создайте CI/CD pipeline

---

## 🚨 **Troubleshooting**

### **Если сервис недоступен:**
1. Проверьте что port-forward запущен
2. Проверьте статус Pod'ов
3. Проверьте логи
4. Перезапустите port-forward

### **Если Pod не запускается:**
1. Проверьте ресурсы кластера
2. Проверьте события
3. Проверьте конфигурацию
4. Проверьте логи

### **Если не хватает ресурсов:**
1. Остановите ненужные сервисы
2. Увеличьте лимиты ресурсов
3. Масштабируйте кластер

---

## 📚 **Дополнительные ресурсы**

### **Официальная документация:**
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [kubectl Reference](https://kubernetes.io/docs/reference/kubectl/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)

### **Практические курсы:**
- [Kubernetes Basics](https://kubernetes.io/docs/tutorials/kubernetes-basics/)
- [CKA Preparation](https://github.com/dgkanatsios/CKAD-exercises)
- [Kubernetes by Example](https://kubernetesbyexample.com/)

---

## 🎉 **Готово к обучению!**

**Следующие шаги:**
1. Запустите все сервисы: `./scripts/start-learning-environment.sh`
2. Начните с [WEB-SERVICES-STATUS.md](./WEB-SERVICES-STATUS.md)
3. Изучайте по этапам согласно этому индексу
4. Практикуйтесь с реальными проектами

**Удачи в изучении Kubernetes!** 🚀

---

**Создано**: $(date)
**Версия**: Kubernetes v1.27.3
**Статус**: Полный индекс готов! 🎉
