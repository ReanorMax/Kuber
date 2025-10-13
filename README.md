# 🚀 Kubernetes Learning Project - Полное руководство

[![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.27.3-blue?style=flat&logo=kubernetes)](https://kubernetes.io/)
[![Prometheus](https://img.shields.io/badge/Prometheus-Monitoring-orange?style=flat&logo=prometheus)](https://prometheus.io/)
[![Grafana](https://img.shields.io/badge/Grafana-Visualization-yellow?style=flat&logo=grafana)](https://grafana.com/)
[![Kind](https://img.shields.io/badge/Kind-Local%20K8s-green?style=flat&logo=docker)](https://kind.sigs.k8s.io/)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat)](LICENSE)

Комплексный проект для изучения Kubernetes с полным мониторинг стеком, GUI инструментами и подробными обучающими материалами.

![Kubernetes Architecture](https://kubernetes.io/images/docs/components-of-kubernetes.svg)

## 🎯 Что включено

### 📚 Обучающие материалы
- **3 подробных урока** от базовых концепций до продвинутых тем
- **Практические упражнения** с реальными примерами
- **Руководство по диагностике** и устранению проблем
- **Архитектурная документация** с диаграммами
- **Сравнение инструментов** и дистрибутивов

### 🛠️ Готовая инфраструктура
- **Kind кластер** - современная альтернатива Minikube
- **Prometheus** - сбор и хранение метрик
- **Grafana** - визуализация и дашборды  
- **Alertmanager** - управление алертами
- **Nginx Ingress** - маршрутизация трафика
- **SSL/TLS** - безопасные соединения
- **Kubernetes Dashboard** - веб-интерфейс управления
- **Lens** (рекомендуется) - мощный GUI клиент

### 🔧 Автоматизация
- Скрипты развертывания и настройки
- Диагностические утилиты
- Примеры кастомных метрик и алертов
- Автоматическая генерация конфигураций

## 🚀 Быстрый старт

### Предварительные требования

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y docker.io kubectl

# Установка Kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Установка Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### Развертывание

```bash
# 1. Клонирование репозитория
git clone https://github.com/ReanorMax/Kuber.git
cd Kuber

# 2. Создание Kind кластера
kind create cluster --config kind-config.yaml

# 3. Развертывание мониторинга
./scripts/deploy-monitoring.sh

# 4. Настройка DNS
./scripts/setup-dns.sh

# 5. Установка примеров
./scripts/setup-monitoring-examples.sh
```

### Доступ к сервисам

После настройки будут доступны:

- 📊 **Grafana**: http://10.19.1.209:3000 (admin/admin123) ✅
- 📈 **Prometheus**: http://10.19.1.209:9090 ✅
- 🚨 **Alertmanager**: http://10.19.1.209:9093 ✅
- 🎯 **Example App**: http://10.19.1.209:8080 ✅

### 🖥️ GUI инструменты для управления

#### Kubernetes Dashboard (веб-интерфейс)
```bash
./scripts/access-dashboard.sh
# Откройте: https://<server-ip>:9443
```

#### Lens (рекомендуется для Windows)
Мощный desktop-клиент для Kubernetes:
- 📥 Скачайте: [k8slens.dev](https://k8slens.dev/)
- 📋 Быстрый старт: [`LENS-QUICKSTART.md`](LENS-QUICKSTART.md)
- 📚 Подробная инструкция: [`docs/lens-setup-guide.md`](docs/lens-setup-guide.md)
- 🔑 Kubeconfig готов: `kubeconfig-for-windows.yaml`

#### Сравнение инструментов
- 📊 [`docs/gui-tools-comparison.md`](docs/gui-tools-comparison.md) - полное сравнение всех GUI инструментов
- 📝 [`docs/gui-tools-quick-summary.md`](docs/gui-tools-quick-summary.md) - краткая сводка

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

### 🚨 Полное руководство по решению проблем
**Файл**: [`docs/troubleshooting-complete-guide.md`](docs/troubleshooting-complete-guide.md)

**ВСЕ ПРОБЛЕМЫ И РЕШЕНИЯ**:
- ✅ Высокая нагрузка на сервер (Minikube + Kind)
- ✅ Grafana Health Check Failures
- ✅ Dashboard неактивная кнопка Sign In
- ✅ Dashboard показывает только 2 пода
- ✅ Port-forward не работает
- 📊 **Актуальные данные для доступа** ко всем сервисам

## 🏗️ Архитектура проекта

```
kubernetes-learning/
├── 📚 docs/                     # Обучающие материалы
│   ├── current-architecture.md   # Документация архитектуры
│   ├── learning-guide-01-*.md    # Уроки по Kubernetes
│   ├── troubleshooting-guide.md  # Руководство по диагностике
│   ├── project-summary.md        # Полное описание проекта
│   └── gui-tools-*.md           # Сравнение GUI инструментов
├── 📦 manifests/                # Kubernetes манифесты
│   ├── monitoring/              # Prometheus stack
│   ├── ingress/                 # Ingress правила
│   ├── apps/                    # Примеры приложений
│   └── dashboard/               # Kubernetes Dashboard
├── ⚙️ helm-values/               # Helm конфигурации
├── 🛠️ scripts/                  # Скрипты автоматизации
│   ├── deploy-monitoring.sh     # Развертывание мониторинга
│   ├── setup-dns.sh            # Настройка DNS
│   ├── access-dashboard.sh     # Доступ к Dashboard
│   └── diagnose-*.sh           # Диагностические скрипты
├── 🔧 kind-config.yaml          # Конфигурация Kind кластера
├── 📋 LENS-QUICKSTART.md        # Быстрый старт с Lens
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
- [ ] Создание дашбордов в Grafana

### 🎯 Фаза 3: Продвинутые темы (3-4 недели)
- [ ] StatefulSets и PersistentVolumes
- [ ] RBAC и безопасность
- [ ] Автоскейлинг и оптимизация
- [ ] Troubleshooting и диагностика

### 🏆 Фаза 4: Практика (4+ недель)
- [ ] Создание собственных приложений
- [ ] Настройка CI/CD пайплайнов
- [ ] Мониторинг production нагрузок
- [ ] Подготовка к сертификации

## 🔧 Полезные команды

### Управление кластером
```bash
# Статус кластера
./scripts/kind-status.sh

# Ежедневные проверки
./scripts/daily-check.sh

# Диагностика проблем
./scripts/diagnose-cluster.sh
```

### Работа с приложениями
```bash
# Диагностика приложения
./scripts/diagnose-app.sh <app-name> <namespace>

# Доступ к Dashboard
./scripts/access-dashboard.sh

# Генерация kubeconfig для Windows
./scripts/generate-windows-kubeconfig.sh
```

### Мониторинг
```bash
# Проверка метрик
kubectl get --raw /metrics

# Логи Prometheus
kubectl logs -n monitoring deployment/prometheus-kube-prometheus-prometheus

# Статус алертов
kubectl get prometheusrules -n monitoring
```

## 🌐 Доступ к сервисам

### 🌐 Прямой доступ (Kind порты) - РЕКОМЕНДУЕТСЯ
- **Grafana**: http://10.19.1.209:3000 (admin/admin123) ✅
- **Prometheus**: http://10.19.1.209:9090 ✅
- **Alertmanager**: http://10.19.1.209:9093 ✅
- **Kubernetes Dashboard**: http://10.19.1.209:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/ ✅

### 🔒 Внешний доступ (через Ingress) - ДОПОЛНИТЕЛЬНО
- **Grafana**: https://grafana.local (admin/admin123)
- **Prometheus**: https://prometheus.local
- **Alertmanager**: https://alertmanager.local
- **Example App**: http://metrics-app.local

### SSH туннель (для Lens)
```bash
ssh -L 6443:127.0.0.1:41917 root@10.19.1.209 -N
```

## 🛠️ Troubleshooting

### 🚨 Все проблемы и решения
**📚 Полное руководство**: [`docs/troubleshooting-complete-guide.md`](docs/troubleshooting-complete-guide.md)

### ⚡ Быстрые решения

**Проблема**: Grafana показывает "Unhealthy"
```bash
# Проверка ресурсов сервера
free -h
docker stats --no-stream

# Если память >90% - остановите неиспользуемые контейнеры
docker stop $(docker ps -q)
```

**Проблема**: Dashboard кнопка "Sign in" неактивна
```bash
# Используйте kubectl proxy вместо port-forward
kubectl proxy --address='0.0.0.0' --port=8001
# URL: http://10.19.1.209:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

**Проблема**: Сервисы недоступны
```bash
# Проверка статуса подов
kubectl get pods --all-namespaces

# Проверка сервисов
kubectl get svc --all-namespaces
```

## 📚 Дополнительные ресурсы

### Официальная документация
- [Kubernetes](https://kubernetes.io/docs/)
- [Prometheus](https://prometheus.io/docs/)
- [Grafana](https://grafana.com/docs/)
- [Kind](https://kind.sigs.k8s.io/docs/)

### Курсы и сертификации
- [Kubernetes Fundamentals](https://training.linuxfoundation.org/training/kubernetes-fundamentals/)
- [CKA Certification](https://www.cncf.io/certification/cka/)
- [Prometheus Certified Associate](https://training.prometheus.io/)

### Сообщество
- [Kubernetes Slack](https://kubernetes.slack.com/)
- [Prometheus Community](https://prometheus.io/community/)
- [Grafana Community](https://community.grafana.com/)

## 🤝 Вклад в проект

Мы приветствуем вклад в развитие проекта! 

### Как помочь:
1. **Fork** репозитория
2. Создайте **feature branch**
3. Внесите изменения
4. Создайте **Pull Request**

### Области для улучшения:
- Новые примеры приложений
- Дополнительные дашборды Grafana
- Скрипты автоматизации
- Переводы документации

## 📄 Лицензия

Этот проект распространяется под лицензией MIT. См. файл [LICENSE](LICENSE) для подробностей.

## 🙏 Благодарности

- [Kubernetes Community](https://kubernetes.io/community/)
- [Prometheus Team](https://prometheus.io/)
- [Grafana Labs](https://grafana.com/)
- [Kind Maintainers](https://kind.sigs.k8s.io/)

---

**Удачного изучения Kubernetes!** 🚀

*Если у вас есть вопросы или предложения, создайте [Issue](https://github.com/ReanorMax/Kuber/issues) в репозитории.*