# ⚡ Быстрые ссылки

> Самые нужные документы одним кликом

## 🚀 **Начать здесь**
- [📚 INDEX - Полный индекс документации](docs/INDEX.md)
- [🏠 README - Главная страница](README.md)
- [🚀 Lens Quickstart - Быстрый старт](LENS-QUICKSTART.md)

---

## 📖 **Обучение (по порядку)**
1. [📘 Урок 1: Основы Kubernetes](docs/learning-guide-01-basics.md)
2. [📦 Pod vs Container - Разница](docs/pods-vs-containers-explained.md)
3. [📗 Урок 2: Сети и мониторинг](docs/learning-guide-02-networking-monitoring.md)
4. [📊 Prometheus Stack - 6 компонентов](docs/prometheus-stack-components.md)
5. [📙 Урок 3: Продвинутые темы](docs/learning-guide-03-advanced-topics.md)

---

## 🔧 **Практика**
- [🔍 Как проверять переменные окружения](docs/how-to-check-env-variables.md)
- [🌐 Проброс портов - как это работает](docs/port-forwarding-explained.md)
- [📊 Визуальная диаграмма портов](docs/port-mapping-diagram.md)
- [🔐 SSH туннель для Kubernetes](docs/ssh-tunnel-explained.md)

---

## 🚨 **Проблемы? Начните здесь!**
- [🚨 Troubleshooting Complete - ВСЕ решения](docs/troubleshooting-complete-guide.md)
- [🔧 Troubleshooting Guide - Базовая диагностика](docs/troubleshooting-guide.md)

---

## 🖥️ **GUI инструменты**
- [🚀 Lens Quickstart](LENS-QUICKSTART.md)
- [🖥️ Lens Setup - Детальная настройка](docs/lens-setup-guide.md)
- [📊 Сравнение GUI](docs/gui-tools-comparison.md)
- [💻 Windows Setup](docs/windows-setup-guide.md)

---

## 🌐 **Доступ к сервисам**

### **Графические интерфейсы**:
- **Grafana**: http://10.19.1.209:3000 (admin/admin123)
- **Prometheus**: http://10.19.1.209:9090
- **Alertmanager**: http://10.19.1.209:9093
- **Dashboard**: http://10.19.1.209:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

### **Токены**:
```bash
# Dashboard admin token
kubectl -n kubernetes-dashboard create token dashboard-admin

# Lens kubeconfig
# Файл: kubeconfig-for-windows.yaml
```

---

## 📁 **Скрипты**

### **Управление кластером**:
```bash
./scripts/kind-status.sh           # Статус Kind кластера
./scripts/daily-check.sh            # Ежедневная проверка
./scripts/diagnose-cluster.sh       # Диагностика кластера
```

### **Доступ к сервисам**:
```bash
./scripts/access-dashboard.sh      # Kubernetes Dashboard
./scripts/fast-dashboard-access.sh  # Оптимизированный доступ
```

### **Развертывание**:
```bash
./scripts/deploy-monitoring.sh     # Установка мониторинга
./scripts/setup-monitoring-examples.sh  # Примеры приложений
```

---

## 🎯 **Сценарии использования**

### **Я новичок**:
1. [README](README.md) → 2. [Урок 1](docs/learning-guide-01-basics.md) → 3. [Pod vs Container](docs/pods-vs-containers-explained.md) → 4. [Lens](LENS-QUICKSTART.md)

### **Нужно понять архитектуру**:
1. [Complete User Guide](docs/complete-user-guide.md) → 2. [Prometheus Stack](docs/prometheus-stack-components.md) → 3. [Проброс портов](docs/port-forwarding-explained.md)

### **Есть проблема**:
1. [Troubleshooting Complete](docs/troubleshooting-complete-guide.md) → 2. [Скрипты диагностики](docs/troubleshooting-guide.md)

### **Хочу настроить Lens**:
1. [Lens Quickstart](LENS-QUICKSTART.md) → 2. [SSH туннель](docs/ssh-tunnel-explained.md) → 3. [Lens Setup](docs/lens-setup-guide.md)

---

## 🔍 **Поиск по темам**

| Тема | Документ |
|------|----------|
| **Pods и контейнеры** | [pods-vs-containers-explained.md](docs/pods-vs-containers-explained.md) |
| **Prometheus** | [prometheus-stack-components.md](docs/prometheus-stack-components.md) |
| **Сеть и порты** | [port-forwarding-explained.md](docs/port-forwarding-explained.md) |
| **SSH туннель** | [ssh-tunnel-explained.md](docs/ssh-tunnel-explained.md) |
| **Переменные окружения** | [how-to-check-env-variables.md](docs/how-to-check-env-variables.md) |
| **Kind настройка** | [kind-infrastructure-setup-guide.md](docs/kind-infrastructure-setup-guide.md) |
| **Lens** | [lens-setup-guide.md](docs/lens-setup-guide.md) |
| **Windows** | [windows-setup-guide.md](docs/windows-setup-guide.md) |
| **Troubleshooting** | [troubleshooting-complete-guide.md](docs/troubleshooting-complete-guide.md) |

---

## 📚 **Полная документация**
➡️ [docs/INDEX.md](docs/INDEX.md) - Полный индекс со всеми документами, описаниями и связями

---

*Добавьте этот файл в закладки для быстрого доступа к документации!*

