# 📚 Полное руководство по Kubernetes Learning Project

## 🎯 Обзор проекта

Этот проект создан для комплексного изучения Kubernetes с полным мониторинг стеком, GUI инструментами и практическими примерами. Все компоненты настроены и готовы к использованию.

---

## 🏗️ Архитектура системы

### Основные компоненты:

```
┌─────────────────────────────────────────────────────────────┐
│                    Kubernetes Learning Environment          │
├─────────────────────────────────────────────────────────────┤
│  🖥️ Kind Cluster (learning-cluster)                        │
│  ├── Control Plane Node                                     │
│  │   ├── API Server (127.0.0.1:41917)                      │
│  │   ├── Port Mappings:                                     │
│  │   │   ├── 3000 → 30080 (Grafana)                       │
│  │   │   ├── 9090 → 30090 (Prometheus)                    │
│  │   │   ├── 9093 → 30093 (Alertmanager)                   │
│  │   │   ├── 8080 → 80 (Ingress HTTP)                      │
│  │   │   └── 8443 → 443 (Ingress HTTPS)                    │
│  │   └── 9443 → 443 (Dashboard HTTPS)                      │
│  └── Worker Nodes (встроенные в Kind)                       │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    Monitoring Stack                        │
├─────────────────────────────────────────────────────────────┤
│  📊 Prometheus Stack (Helm Chart)                          │
│  ├── Prometheus Server (сбор метрик)                       │
│  ├── Grafana (визуализация)                                 │
│  ├── Alertmanager (управление алертами)                     │
│  ├── Node Exporter (метрики узлов)                         │
│  ├── Kube State Metrics (метрики K8s объектов)             │
│  └── Service Monitors (автодискавери)                       │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    Networking Layer                         │
├─────────────────────────────────────────────────────────────┤
│  🌐 Nginx Ingress Controller                               │
│  ├── HTTP: 8080 → 80                                        │
│  ├── HTTPS: 8443 → 443                                      │
│  ├── SSL/TLS сертификаты (self-signed)                     │
│  └── Host-based routing                                     │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    GUI Tools                               │
├─────────────────────────────────────────────────────────────┤
│  🖥️ Kubernetes Dashboard (веб-интерфейс)                 │
│  ├── HTTPS: https://10.19.1.209:9443                       │
│  ├── Аутентификация через токены                           │
│  └── Полный доступ к ресурсам кластера                     │
│                                                             │
│  💻 Lens (desktop-клиент)                                   │
│  ├── Kubeconfig: kubeconfig-for-windows.yaml               │
│  ├── SSH туннель: 6443:127.0.0.1:41917                     │
│  └── Мощный GUI с расширенными возможностями               │
└─────────────────────────────────────────────────────────────┘
```

---

## 📁 Структура Namespace'ов

### 🎯 **Зачем нужны разные namespace'ы**:

1. **Изоляция ресурсов** - разделение приложений
2. **Управление правами доступа** - разные команды видят разные ресурсы
3. **Организация** - логическое группирование
4. **Безопасность** - ограничение доступа между приложениями

### 📊 **Ваши namespace'ы**:

| Namespace | Назначение | Что содержит | Количество подов |
|-----------|------------|--------------|------------------|
| **`default`** | Основные приложения | nginx-demo, example-metrics-app | 2 пода |
| **`monitoring`** | Мониторинг стек | Prometheus, Grafana, Alertmanager | 6 подов |
| **`demo-apps`** | Демо приложения | Redis, CronJobs, Jobs | 5 подов |
| **`kubernetes-dashboard`** | Веб-интерфейс | Сам Dashboard | 2 пода |
| **`ingress-nginx`** | Сетевая инфраструктура | Ingress контроллер | Системные поды |
| **`kube-system`** | Системные компоненты | CoreDNS, kube-proxy | Системные поды |

### 💡 **Примеры использования namespace'ов**:

```bash
# Разные команды видят разные ресурсы
kubectl get pods -n monitoring    # Только мониторинг
kubectl get pods -n demo-apps    # Только демо приложения
kubectl get pods -n default      # Основные приложения

# Разные права доступа
kubectl create role developer --resource=pods --verb=get,list -n demo-apps
kubectl create role admin --resource=* --verb=* -n monitoring
```

---

## 🖥️ Настройка GUI инструментов

### 1️⃣ **Kubernetes Dashboard (веб-интерфейс)**

#### **Доступ через kubectl proxy**:
```bash
# На сервере
kubectl proxy --address='0.0.0.0' --accept-hosts='.*' --port=8001

# На Windows откройте:
http://10.19.1.209:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

#### **Токен для входа**:
```bash
# Генерация токена
kubectl -n kubernetes-dashboard create token dashboard-admin
```

#### **Как переключаться между namespace'ами**:
1. Войдите в Dashboard с токеном
2. Найдите **селектор namespace** в верхней части
3. Выберите нужный namespace из выпадающего списка
4. Теперь видите все ресурсы выбранного namespace'а

### 2️⃣ **Lens (рекомендуется для Windows)**

#### **Шаг 1: Создайте SSH туннель на Windows**

Откройте **PowerShell** или **CMD** на Windows:

```powershell
ssh -L 6443:127.0.0.1:41917 root@10.19.1.209 -N
```

**Важно**: Оставьте это окно открытым!

#### **Шаг 2: Скопируйте kubeconfig на Windows**

```powershell
# Способ 1: Через SCP
scp root@10.19.1.209:/root/kubernetes-learning/kubeconfig-for-windows.yaml C:\Users\<Username>\.kube\config

# Способ 2: Вручную
# Скопируйте содержимое файла kubeconfig-for-windows.yaml
# Создайте файл C:\Users\<Username>\.kube\config
# Вставьте содержимое
```

#### **Шаг 3: Установите Lens**

1. Скачайте: https://k8slens.dev/
2. Установите на Windows
3. Откройте Lens

#### **Шаг 4: Импорт кластера**

**Вариант A: Автоматический импорт**
- Lens автоматически обнаружит кластер из `~/.kube/config`
- Кластер появится в списке как **"kind-learning-cluster"**

**Вариант B: Ручной импорт**
1. **File → Add Cluster**
2. Скопируйте содержимое `kubeconfig-for-windows.yaml`
3. Вставьте в Lens
4. Нажмите **Add Cluster**

#### **Преимущества Lens**:
- ✅ **Все namespace'ы видны сразу**
- ✅ **Легко переключаться** между ними
- ✅ **Быстрая работа** - нет проблем с сертификатами
- ✅ **Мощные возможности** - логи, терминал, редактирование
- ✅ **Несколько кластеров** одновременно

---

## 🌐 Доступ к сервисам

### **Внешний доступ (через Ingress)**:
- **Grafana**: https://grafana.local (admin/admin123)
- **Prometheus**: https://prometheus.local
- **Alertmanager**: https://alertmanager.local
- **Example App**: http://metrics-app.local

### **Прямой доступ (Kind порты)**:
- **Grafana**: http://10.19.1.209:3000
- **Prometheus**: http://10.19.1.209:9090
- **Alertmanager**: http://10.19.1.209:9093
- **Dashboard**: https://10.19.1.209:9443

### **SSH туннель (для Lens)**:
```bash
ssh -L 6443:127.0.0.1:41917 root@10.19.1.209 -N
```

---

## 🔧 Troubleshooting

### **Проблема: Dashboard показывает только 2 пода**

**Причина**: Dashboard по умолчанию показывает только namespace `default`

**Решение**:
1. Войдите в Dashboard с токеном `dashboard-admin`
2. Найдите селектор namespace в верхней части
3. Выберите нужный namespace из выпадающего списка

### **Проблема: SSH туннель не работает**
```bash
# Проверьте подключение
ping 10.19.1.209

# Проверьте SSH
ssh root@10.19.1.209
```

### **Проблема: Lens не видит кластер**
```bash
# Проверьте kubeconfig
kubectl config view

# Проверьте подключение
kubectl get nodes
```

### **Проблема: Токен не работает**
```bash
# Сгенерируйте новый токен
kubectl -n kubernetes-dashboard create token dashboard-admin
```

---

## 📊 Мониторинг и метрики

### **Автоматически собираемые метрики**:
- **Node метрики**: CPU, память, диск, сеть
- **Kubernetes метрики**: поды, сервисы, deployments
- **Application метрики**: кастомные метрики из примеров
- **Ingress метрики**: трафик и ошибки

### **Дашборды Grafana**:
- **Kubernetes Cluster Overview**: обзор кластера
- **Application Monitoring**: мониторинг приложений
- **Node Exporter**: метрики узлов
- **Prometheus Stats**: статистика Prometheus

### **Алерты**:
- **High CPU Usage**: высокое использование CPU
- **High Memory Usage**: высокое использование памяти
- **Pod CrashLoopBackOff**: проблемы с подами
- **Service Down**: недоступность сервисов

---

## 🎓 План обучения

### **Фаза 1: Основы (1-2 недели)**
- [ ] Изучение архитектуры Kubernetes
- [ ] Работа с основными объектами
- [ ] Практика с kubectl
- [ ] Развертывание первого приложения

### **Фаза 2: Сети и мониторинг (2-3 недели)**
- [ ] Понимание сетевой модели
- [ ] Настройка Service Discovery
- [ ] Изучение Prometheus и PromQL
- [ ] Создание дашбордов в Grafana

### **Фаза 3: Продвинутые темы (3-4 недели)**
- [ ] StatefulSets и PersistentVolumes
- [ ] RBAC и безопасность
- [ ] Автоскейлинг и оптимизация
- [ ] Troubleshooting и диагностика

### **Фаза 4: Практика (4+ недель)**
- [ ] Создание собственных приложений
- [ ] Настройка CI/CD пайплайнов
- [ ] Мониторинг production нагрузок
- [ ] Подготовка к сертификации

---

## 🛠️ Полезные команды

### **Управление кластером**:
```bash
# Статус кластера
./scripts/kind-status.sh

# Ежедневные проверки
./scripts/daily-check.sh

# Диагностика проблем
./scripts/diagnose-cluster.sh
```

### **Работа с приложениями**:
```bash
# Диагностика приложения
./scripts/diagnose-app.sh <app-name> <namespace>

# Доступ к Dashboard
./scripts/access-dashboard.sh

# Генерация kubeconfig для Windows
./scripts/generate-windows-kubeconfig.sh
```

### **Мониторинг**:
```bash
# Проверка метрик
kubectl get --raw /metrics

# Логи Prometheus
kubectl logs -n monitoring deployment/prometheus-kube-prometheus-prometheus

# Статус алертов
kubectl get prometheusrules -n monitoring
```

---

## 🔐 Безопасность

### **Реализованные меры**:
- **SSL/TLS**: все веб-интерфейсы через HTTPS
- **RBAC**: настроены права доступа для Dashboard
- **Secrets**: пароли и токены в Kubernetes Secrets
- **Network Policies**: изоляция трафика (опционально)

### **Исключения из Git**:
- Приватные ключи и сертификаты
- Токены аутентификации
- Пароли и секреты
- Локальные конфигурации

---

## 📚 Дополнительные ресурсы

### **Официальная документация**:
- [Kubernetes](https://kubernetes.io/docs/)
- [Prometheus](https://prometheus.io/docs/)
- [Grafana](https://grafana.com/docs/)
- [Kind](https://kind.sigs.k8s.io/docs/)

### **Курсы и сертификации**:
- [Kubernetes Fundamentals](https://training.linuxfoundation.org/training/kubernetes-fundamentals/)
- [CKA Certification](https://www.cncf.io/certification/cka/)
- [Prometheus Certified Associate](https://training.prometheus.io/)

### **Сообщество**:
- [Kubernetes Slack](https://kubernetes.slack.com/)
- [Prometheus Community](https://prometheus.io/community/)
- [Grafana Community](https://community.grafana.com/)

---

## 🎯 Рекомендации

### **Для начинающих**:
1. **Начните с Kubernetes Dashboard** для понимания веб-доступа
2. **Установите Lens** на Windows для удобной работы
3. **Попробуйте k9s** на сервере для эффективности в терминале
4. **Всегда держите под рукой kubectl** для автоматизации

### **Почему именно Lens**:
- Самый удобный для обучения
- Визуальное понимание архитектуры
- Простой доступ к логам и ресурсам
- Не нужно настраивать port-forward каждый раз
- Работает нативно на Windows

### **Почему Kubernetes Dashboard**:
- Понимание веб-доступа к кластеру
- Изучение RBAC и аутентификации
- Практика работы с Ingress и Services
- Облегченный вариант для быстрого доступа

---

*Этот проект создан для комплексного изучения Kubernetes с практическим подходом и готовой инфраструктурой для экспериментов.*
