# 🚀 Kubernetes Learning Project

[![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.34-blue?style=flat&logo=kubernetes)](https://kubernetes.io/)
[![Prometheus](https://img.shields.io/badge/Prometheus-Monitoring-orange?style=flat&logo=prometheus)](https://prometheus.io/)
[![Grafana](https://img.shields.io/badge/Grafana-Visualization-yellow?style=flat&logo=grafana)](https://grafana.com/)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat)](LICENSE)

Комплексный проект для изучения Kubernetes с полным мониторинг стеком и подробными обучающими материалами.

![Kubernetes Architecture](https://kubernetes.io/images/docs/components-of-kubernetes.svg)

## 🎯 Что включено

### 📚 Обучающие материалы
- **3 подробных урока** от базовых концепций до продвинутых тем
- **Практические упражнения** с реальными примерами
- **Руководство по диагностике** и устранению проблем
- **Архитектурная документация** с диаграммами

### 🛠️ Готовая инфраструктура
- **Prometheus** - сбор и хранение метрик
- **Grafana** - визуализация и дашборды  
- **Alertmanager** - управление алертами
- **Nginx Ingress** - маршрутизация трафика
- **SSL/TLS** - безопасные соединения

### 🔧 Автоматизация
- Скрипты развертывания и настройки
- Диагностические утилиты
- Примеры кастомных метрик и алертов

## 🚀 Быстрый старт

### Предварительные требования

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y docker.io kubectl

# Установка Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Установка Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### Развертывание

```bash
# 1. Клонирование репозитория
git clone https://github.com/ReanorMax/Kuber.git
cd Kuber

# 2. Запуск Minikube кластера
minikube start --memory=4096 --cpus=2

# 3. Развертывание мониторинга
./scripts/deploy-monitoring.sh

# 4. Настройка DNS
./scripts/setup-dns.sh

# 5. Установка примеров
./scripts/setup-monitoring-examples.sh
```

### Доступ к сервисам

После настройки будут доступны:

- 📊 **Grafana**: https://grafana.local (admin/admin123)
- 📈 **Prometheus**: https://prometheus.local  
- 🚨 **Alertmanager**: https://alertmanager.local
- 🎯 **Example App**: http://metrics-app.local

## 📖 Обучающие материалы

### 📘 Урок 1: Основы Kubernetes
**Файл**: [`docs/learning-guide-01-basics.md`](docs/learning-guide-01-basics.md)

Изучите:
- Основные объекты Kubernetes (Pods, Deployments, Services)
- Взаимодействие компонентов
- Практические упражнения с kubectl
- Создание собственного приложения

### 📗 Урок 2: Сети и мониторинг  
**Файл**: [`docs/learning-guide-02-networking-monitoring.md`](docs/learning-guide-02-networking-monitoring.md)

Изучите:
- Сетевая модель Kubernetes
- Service Discovery и DNS
- Архитектура Prometheus
- Создание дашбордов в Grafana

### 📙 Урок 3: Продвинутые темы
**Файл**: [`docs/learning-guide-03-advanced-topics.md`](docs/learning-guide-03-advanced-topics.md)

Изучите:
- StatefulSets и Persistent Storage
- RBAC и безопасность
- Автоскейлинг (HPA/VPA)
- Network Policies

### 🔧 Диагностика и troubleshooting
**Файл**: [`docs/troubleshooting-guide.md`](docs/troubleshooting-guide.md)

Научитесь:
- Диагностировать проблемы кластера
- Анализировать логи и события
- Отлаживать сетевые проблемы
- Использовать инструменты мониторинга

## 🏗️ Архитектура проекта

```
kubernetes-learning/
├── 📚 docs/                     # Обучающие материалы
│   ├── current-architecture.md   # Документация архитектуры
│   ├── learning-guide-01-*.md    # Уроки по Kubernetes
│   └── troubleshooting-guide.md  # Руководство по диагностике
├── 📦 manifests/                # Kubernetes манифесты
│   ├── monitoring/              # Prometheus stack
│   ├── ingress/                 # Ingress правила
│   └── apps/                    # Примеры приложений
├── ⚙️ helm-values/               # Helm конфигурации
├── 🛠️ scripts/                  # Скрипты автоматизации
│   ├── deploy-monitoring.sh     # Развертывание мониторинга
│   ├── setup-dns.sh            # Настройка DNS
│   └── diagnose-*.sh           # Диагностические скрипты
└── 📋 README.md                 # Основная документация
```

## 🎓 План обучения

### 🌟 Фаза 1: Основы (1-2 недели)
- [ ] Изучение архитектуры Kubernetes
- [ ] Работа с основными объектами
- [ ] Практика с kubectl
- [ ] Развертывание первого приложения

### 🚀 Фаза 2: Сети и мониторинг (2-3 недели)  
- [ ] Понимание сетевой модели
- [ ] Настройка Service Discovery
- [ ] Изучение Prometheus и PromQL
- [ ] Создание дашбордов Grafana

### 🔥 Фаза 3: Продвинутые темы (3-4 недели)
- [ ] StatefulSets и хранилище данных
- [ ] RBAC и безопасность
- [ ] Автоскейлинг приложений
- [ ] Диагностика и troubleshooting

## 📊 Примеры дашбордов

В проекте включены готовые дашборды Grafana:

- **Kubernetes Cluster Overview** - общий обзор кластера
- **Application Monitoring** - мониторинг приложений  
- **Learning Dashboard** - базовые примеры PromQL
- **Monitoring Stack Health** - состояние мониторинга

## 🔍 Диагностические инструменты

```bash
# Общая диагностика кластера
./scripts/diagnose-cluster.sh

# Диагностика конкретного приложения
./scripts/diagnose-app.sh <app-name> [namespace]

# Информация о кластере
./scripts/cluster-info.sh
```

## 🛡️ Безопасность

Проект включает:
- SSL/TLS сертификаты для всех сервисов
- Базовые настройки RBAC
- Примеры Network Policies
- `.gitignore` для исключения чувствительных данных

## 🤝 Участие в проекте

Проект создан для обучения. Вы можете:

1. **Fork** репозиторий
2. Добавить свои **примеры и упражнения**  
3. Улучшить **документацию**
4. Поделиться **опытом** в Issues

## 📝 Полезные команды

```bash
# Проверка статуса всех сервисов
kubectl get all -A

# Просмотр метрик (если metrics-server установлен)
kubectl top nodes
kubectl top pods -A

# Проверка Ingress
kubectl get ingress -A

# Логи мониторинга
kubectl logs -n monitoring deployment/prometheus-grafana -f
```

## 🔗 Полезные ссылки

- [Официальная документация Kubernetes](https://kubernetes.io/docs/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Tutorials](https://grafana.com/tutorials/)
- [Helm Charts](https://helm.sh/docs/)

## 📞 Поддержка

Если у вас есть вопросы или предложения:
- Создайте **Issue** в репозитории
- Изучите документацию в папке `docs/`
- Используйте скрипты диагностики

---

**🌟 Звезды приветствуются! Поделитесь проектом с коллегами изучающими Kubernetes.**

**📚 Хорошего изучения Kubernetes!**
