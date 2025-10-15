# 🚀 Kubernetes Learning Environment

Полная обучающая среда для изучения Kubernetes с веб-интерфейсами, мониторингом и автоматизацией.

## 🎯 **Начните здесь!**

### **⚡ Быстрый старт (5 минут)**
```bash
cd /root/kubernetes-learning
./scripts/start-learning-environment.sh
```

### **📚 Главный индекс для изучения**
👉 **[LEARNING-INDEX.md](./LEARNING-INDEX.md)** - Полное руководство по изучению

### **⚡ Быстрая справка**
👉 **[QUICK-REFERENCE.md](./QUICK-REFERENCE.md)** - Все команды и ссылки

---

## 🌐 **Доступ к сервисам**

| Сервис | URL | Логин | Пароль |
|--------|-----|-------|--------|
| **K8s Dashboard** | https://10.19.1.209:30443 | Токен | [длительный токен] |
| **Grafana** | http://10.19.1.209:30300 | admin | grafana123 |
| **ArgoCD** | http://10.19.1.209:30444 | admin | Q15LKJNm7K0WAFdw |
| **Prometheus** | http://10.19.1.209:30090 | - | - |
| **Alertmanager** | http://10.19.1.209:30093 | - | - |
| **PostgreSQL** | 10.19.1.209:30432 | admin | admin123 |

---

## 📖 **Основная документация**

### **🔧 Управление и доступ**
- **[LEARNING-INDEX.md](./LEARNING-INDEX.md)** - Главный индекс для изучения
- **[QUICK-REFERENCE.md](./QUICK-REFERENCE.md)** - Быстрая справка
- **[WEB-SERVICES-STATUS.md](./WEB-SERVICES-STATUS.md)** - Статус всех сервисов
- **[PORT-FORWARDING-COMPLETE-GUIDE.md](./PORT-FORWARDING-COMPLETE-GUIDE.md)** - Полное руководство по пробросу портов

### **🗄️ Работа с данными**
- **[POSTGRESQL-LEARNING-GUIDE.md](./POSTGRESQL-LEARNING-GUIDE.md)** - Подробный гайд по PostgreSQL
- **[KAFKA-LEARNING-GUIDE.md](./KAFKA-LEARNING-GUIDE.md)** - Подробный гайд по Kafka

### **🚀 Автоматизация**
- **[ARGOCD-GUIDE.md](./ARGOCD-GUIDE.md)** - GitOps с ArgoCD

### **📊 Общее руководство**
- **[COMPLETE-LEARNING-ENVIRONMENT.md](./COMPLETE-LEARNING-ENVIRONMENT.md)** - Полное руководство по среде обучения

---

## 🎓 **Порядок изучения**

### **Этап 1: Основы (1-2 недели)**
1. Kubernetes Dashboard - управление кластером
2. kubectl команды - работа с ресурсами
3. Pod'ы и Deployment'ы - основы

### **Этап 2: Данные (1-2 недели)**
1. PostgreSQL - базы данных в Kubernetes
2. Kafka - потоковая обработка данных

### **Этап 3: Мониторинг (1 неделя)**
1. Grafana - дашборды и визуализация
2. Prometheus - сбор метрик

### **Этап 4: Автоматизация (1-2 недели)**
1. ArgoCD - GitOps подход
2. Helm - управление приложениями

---

## 🛠️ **Основные команды**

### **Запуск всех сервисов:**
```bash
./scripts/start-learning-environment.sh
```

### **Проверка статуса:**
```bash
kubectl get pods --all-namespaces
ps aux | grep "kubectl port-forward"
netstat -tlnp | grep -E "(30443|30300|30444|30090|30093)"
```

### **Остановка:**
```bash
pkill -f "kubectl port-forward"
```

---

## 🚨 **Troubleshooting**

Если что-то не работает:
1. Проверьте [QUICK-REFERENCE.md](./QUICK-REFERENCE.md)
2. Изучите [PORT-FORWARDING-COMPLETE-GUIDE.md](./PORT-FORWARDING-COMPLETE-GUIDE.md)
3. Проверьте [WEB-SERVICES-STATUS.md](./WEB-SERVICES-STATUS.md)

---

## 🎉 **Готово к обучению!**

**Следующие шаги:**
1. Запустите все сервисы: `./scripts/start-learning-environment.sh`
2. Начните с [LEARNING-INDEX.md](./LEARNING-INDEX.md)
3. Изучайте по этапам согласно индексу
4. Практикуйтесь с реальными проектами

**Удачи в изучении Kubernetes!** 🚀