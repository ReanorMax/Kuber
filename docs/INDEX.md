# 📚 Полный индекс документации Kubernetes Learning Project

## 🎯 Навигация по документам

### 📖 **Начните здесь**
- [README.md](../README.md) - **Главная страница** проекта
- [LENS-QUICKSTART.md](../LENS-QUICKSTART.md) - **Быстрый старт** с Lens

---

## 🎓 **Обучающие материалы (Начинающим)**

### Основной курс (по порядку):
1. [learning-guide-01-basics.md](learning-guide-01-basics.md) - **Урок 1: Основы Kubernetes**
   - Pods, Deployments, Services
   - Команды kubectl
   - Практические упражнения

2. [learning-guide-02-networking-monitoring.md](learning-guide-02-networking-monitoring.md) - **Урок 2: Сети и мониторинг**
   - Сетевая модель Kubernetes
   - Service Discovery
   - Prometheus и Grafana

3. [learning-guide-03-advanced-topics.md](learning-guide-03-advanced-topics.md) - **Урок 3: Продвинутые темы**
   - StatefulSets
   - RBAC и безопасность
   - Автоскейлинг

---

## 🔍 **Архитектура и концепции (Важное)**

### Фундаментальные концепции:
- [pods-vs-containers-explained.md](pods-vs-containers-explained.md) - **Pod vs Container**
  - В чем разница?
  - Multi-container паттерны (Sidecar, Adapter, Ambassador)
  - Практические примеры
  - ➡️ **Читать после**: [Урок 1](learning-guide-01-basics.md)

- [configmaps-explained.md](configmaps-explained.md) - **ConfigMaps: конфигурация в Kubernetes** ⭐
  - Что такое ConfigMap?
  - Почему их так много (54 штуки!)
  - Как система понимает куда их "тащить"
  - Готовые конфиги vs ручные
  - ConfigMap vs Secret
  - ➡️ **Читать после**: [Урок 1](learning-guide-01-basics.md)

- [prometheus-stack-components.md](prometheus-stack-components.md) - **Prometheus Stack: все 6 компонентов**
  - Prometheus Server - сбор метрик
  - Alertmanager - управление алертами
  - Grafana - визуализация
  - Operator, Kube State Metrics, Node Exporter
  - Как они взаимодействуют
  - ➡️ **Читать после**: [Урок 2](learning-guide-02-networking-monitoring.md)

### Сетевые концепции:
- [port-forwarding-explained.md](port-forwarding-explained.md) - **Проброс портов: теория**
  - 3 уровня проброса (Docker → NodePort → Service)
  - Почему используются эти порты?
  - Где настроено?
  - ➡️ **Читать вместе с**: [port-mapping-diagram.md](port-mapping-diagram.md)

- [port-mapping-diagram.md](port-mapping-diagram.md) - **Проброс портов: визуализация**
  - Диаграммы цепочки проброса
  - Таблицы всех портов
  - Команды для проверки
  - ➡️ **Читать после**: [port-forwarding-explained.md](port-forwarding-explained.md)

- [ssh-tunnel-explained.md](ssh-tunnel-explained.md) - **SSH туннель для Kubernetes API**
  - Как работает `ssh -L 6443:127.0.0.1:41917`
  - Почему порт 41917?
  - Автоматизация для Windows
  - ➡️ **Читать при настройке**: [Lens](../LENS-QUICKSTART.md)

---

## 🛠️ **Практические инструкции (How-To)**

### Работа с кластером:
- [kind-infrastructure-setup-guide.md](kind-infrastructure-setup-guide.md) - **Как был настроен Kind кластер**
  - Установка софта
  - Создание кластера
  - Развертывание мониторинга
  - ➡️ **Использовать для**: Воссоздания кластера

- [how-to-check-env-variables.md](how-to-check-env-variables.md) - **Проверка переменных окружения**
  - Через kubectl (exec, describe, get)
  - Через Lens (GUI + Shell)
  - Получение значений из Secret
  - Практические задания
  - ➡️ **Связано с**: [prometheus-stack-components.md](prometheus-stack-components.md)

- [awx-deployment-guide.md](awx-deployment-guide.md) - **AWX в Kubernetes для деплоя на серверы** ⭐
  - Можно ли деплоить на внешние серверы? (ДА!)
  - Установка AWX через Operator
  - Настройка SSH ключей и Inventory
  - Как AWX из K8s подключается к серверам
  - Практический пример деплоя
  - ➡️ **Продвинутое использование**: Автоматизация инфраструктуры

### GUI инструменты:
- [gui-tools-comparison.md](gui-tools-comparison.md) - **Сравнение GUI инструментов**
  - Lens (Desktop) - рекомендуется
  - Kubernetes Dashboard (Web)
  - k9s (Terminal)
  - ➡️ **Быстрый старт**: [gui-tools-quick-summary.md](gui-tools-quick-summary.md)

- [gui-tools-quick-summary.md](gui-tools-quick-summary.md) - **Краткая сводка GUI**
  - Быстрый выбор инструмента
  - Основные команды
  - ➡️ **Детали в**: [gui-tools-comparison.md](gui-tools-comparison.md)

### Автоматизация и развертывание:
- [awx-deployment-guide.md](awx-deployment-guide.md) - **AWX: Платформа автоматизации Ansible** ⭐
  - Развертывание AWX в Kubernetes
  - Управление playbooks и инвентарем
  - Развертывание на внешние сервера
  - Job Templates и Credentials
  - ➡️ **Читать после**: [Урок 3](learning-guide-03-advanced-topics.md)

- [lens-setup-guide.md](lens-setup-guide.md) - **Подробная настройка Lens**
  - Установка
  - Подключение к кластеру
  - SSH туннель
  - ➡️ **Быстрый старт**: [LENS-QUICKSTART.md](../LENS-QUICKSTART.md)

### Дистрибутивы Kubernetes:
- [kubernetes-distributions-comparison.md](kubernetes-distributions-comparison.md) - **Сравнение дистрибутивов**
  - Minikube vs Kind vs K3s
  - Когда что использовать
  - Плюсы и минусы
  - ➡️ **Мы используем**: Kind (см. [kind-infrastructure-setup-guide.md](kind-infrastructure-setup-guide.md))

---

## 🚨 **Troubleshooting (Решение проблем)**

### Основные гайды:
- [troubleshooting-guide.md](troubleshooting-guide.md) - **Базовая диагностика**
  - Проблемы кластера
  - Проблемы приложений
  - Скрипты диагностики
  - ➡️ **Более полный**: [troubleshooting-complete-guide.md](troubleshooting-complete-guide.md)

- [troubleshooting-complete-guide.md](troubleshooting-complete-guide.md) - **Все проблемы и решения** ⭐
  - Высокая нагрузка на сервер
  - Grafana Health Check Failures
  - Dashboard неактивная кнопка Sign In
  - Dashboard показывает только 2 пода
  - Port-forward не работает
  - Актуальные данные доступа
  - ➡️ **Читать при проблемах**: Сначала этот файл!

---

## 📊 **Архитектура и документация**

### Обзорные документы:
- [current-architecture.md](current-architecture.md) - **Текущая архитектура**
  - Описание кластера
  - Компоненты
  - Сервисы
  - ➡️ **Актуальная версия**: [complete-user-guide.md](complete-user-guide.md)

- [complete-user-guide.md](complete-user-guide.md) - **Полный гайд пользователя** ⭐
  - Архитектура
  - Namespaces
  - GUI инструменты
  - Troubleshooting
  - Обучение
  - Команды
  - ➡️ **Все в одном месте**: Начните с этого!

- [project-summary.md](project-summary.md) - **Сводка проекта**
  - Что было сделано
  - Структура проекта
  - Как все работает
  - ➡️ **Для понимания**: Общей картины

### Специальные документы:
- [windows-setup-guide.md](windows-setup-guide.md) - **Настройка для Windows**
  - SSH туннель
  - hosts файл
  - PowerShell скрипты
  - ➡️ **Для Windows пользователей**: Обязательно!

- [MINIKUBE-CLEANUP.md](../MINIKUBE-CLEANUP.md) - **Удаление Minikube**
  - Как был удален Minikube
  - Почему перешли на Kind
  - ➡️ **История проекта**

---

## 🗂️ **Быстрые ссылки по темам**

### 🔰 **Новичкам начать здесь**:
1. [README.md](../README.md) - Обзор проекта
2. [learning-guide-01-basics.md](learning-guide-01-basics.md) - Основы Kubernetes
3. [pods-vs-containers-explained.md](pods-vs-containers-explained.md) - Pod vs Container
4. [gui-tools-quick-summary.md](gui-tools-quick-summary.md) - Выбор GUI инструмента
5. [LENS-QUICKSTART.md](../LENS-QUICKSTART.md) - Быстрый старт с Lens

### 🎓 **Обучение (по порядку)**:
1. [learning-guide-01-basics.md](learning-guide-01-basics.md) → Основы
2. [pods-vs-containers-explained.md](pods-vs-containers-explained.md) → Концепции
3. [learning-guide-02-networking-monitoring.md](learning-guide-02-networking-monitoring.md) → Сети
4. [prometheus-stack-components.md](prometheus-stack-components.md) → Мониторинг
5. [port-forwarding-explained.md](port-forwarding-explained.md) → Проброс портов
6. [learning-guide-03-advanced-topics.md](learning-guide-03-advanced-topics.md) → Продвинутые темы

### 🔍 **Понимание архитектуры**:
- [pods-vs-containers-explained.md](pods-vs-containers-explained.md) - Как устроены Pod'ы
- [prometheus-stack-components.md](prometheus-stack-components.md) - Компоненты мониторинга
- [port-forwarding-explained.md](port-forwarding-explained.md) - Как работает сеть
- [port-mapping-diagram.md](port-mapping-diagram.md) - Визуальные диаграммы
- [ssh-tunnel-explained.md](ssh-tunnel-explained.md) - SSH туннелирование

### 🛠️ **Практика и настройка**:
- [kind-infrastructure-setup-guide.md](kind-infrastructure-setup-guide.md) - Настройка кластера
- [how-to-check-env-variables.md](how-to-check-env-variables.md) - Работа с переменными
- [lens-setup-guide.md](lens-setup-guide.md) - Настройка Lens
- [windows-setup-guide.md](windows-setup-guide.md) - Windows конфигурация

### 🚨 **Проблемы и их решение**:
- [troubleshooting-complete-guide.md](troubleshooting-complete-guide.md) - **Начать здесь!**
- [troubleshooting-guide.md](troubleshooting-guide.md) - Базовая диагностика
- Специфичные проблемы см. в [troubleshooting-complete-guide.md](troubleshooting-complete-guide.md)

### 🖥️ **GUI инструменты**:
- [gui-tools-quick-summary.md](gui-tools-quick-summary.md) - Быстрый выбор
- [gui-tools-comparison.md](gui-tools-comparison.md) - Подробное сравнение
- [LENS-QUICKSTART.md](../LENS-QUICKSTART.md) - Lens быстрый старт
- [lens-setup-guide.md](lens-setup-guide.md) - Lens подробно

---

## 📁 **Структура документации**

```
kubernetes-learning/
├── README.md                        # 🏠 Главная страница
├── LENS-QUICKSTART.md              # ⚡ Быстрый старт с Lens
└── docs/
    ├── INDEX.md                     # 📚 Этот файл (навигация)
    │
    ├── 🎓 Обучающие материалы
    │   ├── learning-guide-01-basics.md
    │   ├── learning-guide-02-networking-monitoring.md
    │   └── learning-guide-03-advanced-topics.md
    │
    ├── 🔍 Архитектура и концепции
    │   ├── pods-vs-containers-explained.md
    │   ├── prometheus-stack-components.md
    │   ├── port-forwarding-explained.md
    │   ├── port-mapping-diagram.md
    │   └── ssh-tunnel-explained.md
    │
    ├── 🛠️ Практические инструкции
    │   ├── kind-infrastructure-setup-guide.md
    │   ├── how-to-check-env-variables.md
    │   ├── gui-tools-comparison.md
    │   ├── gui-tools-quick-summary.md
    │   ├── lens-setup-guide.md
    │   ├── kubernetes-distributions-comparison.md
    │   └── windows-setup-guide.md
    │
    ├── 🚨 Troubleshooting
    │   ├── troubleshooting-complete-guide.md  # ⭐ Главный
    │   └── troubleshooting-guide.md
    │
    └── 📊 Обзорные документы
        ├── complete-user-guide.md            # ⭐ Все в одном
        ├── current-architecture.md
        └── project-summary.md
```

---

## 🎯 **Сценарии использования**

### **Сценарий 1: "Я новичок в Kubernetes"**
1. Начните с [README.md](../README.md)
2. Изучите [learning-guide-01-basics.md](learning-guide-01-basics.md)
3. Разберитесь с [pods-vs-containers-explained.md](pods-vs-containers-explained.md)
4. Установите GUI: [LENS-QUICKSTART.md](../LENS-QUICKSTART.md)
5. Продолжайте [learning-guide-02-networking-monitoring.md](learning-guide-02-networking-monitoring.md)

### **Сценарий 2: "Хочу понять архитектуру проекта"**
1. [complete-user-guide.md](complete-user-guide.md) - общий обзор
2. [prometheus-stack-components.md](prometheus-stack-components.md) - мониторинг
3. [port-forwarding-explained.md](port-forwarding-explained.md) - сеть
4. [kind-infrastructure-setup-guide.md](kind-infrastructure-setup-guide.md) - как все настроено

### **Сценарий 3: "У меня проблема"**
1. [troubleshooting-complete-guide.md](troubleshooting-complete-guide.md) - проверьте решения
2. Если не нашли - [troubleshooting-guide.md](troubleshooting-guide.md)
3. Используйте скрипты диагностики из `scripts/diagnose-*.sh`

### **Сценарий 4: "Хочу настроить Lens на Windows"**
1. [LENS-QUICKSTART.md](../LENS-QUICKSTART.md) - быстрый старт
2. [ssh-tunnel-explained.md](ssh-tunnel-explained.md) - понять SSH туннель
3. [lens-setup-guide.md](lens-setup-guide.md) - детальная настройка
4. [windows-setup-guide.md](windows-setup-guide.md) - специфика Windows

### **Сценарий 5: "Хочу разобраться в Prometheus"**
1. [learning-guide-02-networking-monitoring.md](learning-guide-02-networking-monitoring.md) - теория
2. [prometheus-stack-components.md](prometheus-stack-components.md) - все компоненты
3. [how-to-check-env-variables.md](how-to-check-env-variables.md) - практика

### **Сценарий 6: "Не понимаю как работает сеть"**
1. [port-forwarding-explained.md](port-forwarding-explained.md) - теория
2. [port-mapping-diagram.md](port-mapping-diagram.md) - визуализация
3. [learning-guide-02-networking-monitoring.md](learning-guide-02-networking-monitoring.md) - общая теория
4. [ssh-tunnel-explained.md](ssh-tunnel-explained.md) - SSH туннели

---

## 🔗 **Внешние ресурсы**

### Официальная документация:
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Kind Documentation](https://kind.sigs.k8s.io/docs/)
- [Lens Documentation](https://docs.k8slens.dev/)

### Наш GitHub:
- [Repository](https://github.com/ReanorMax/Kuber)
- [Issues](https://github.com/ReanorMax/Kuber/issues)

---

## 💡 **Советы по навигации**

1. **Используйте Ctrl+F** для поиска по этому индексу
2. **Следуйте стрелкам ➡️** для связанных документов
3. **Звездочка ⭐** отмечает ключевые документы
4. **Читайте по порядку** в разделе "Обучающие материалы"
5. **Используйте сценарии** для быстрого старта

---

**Удачного изучения Kubernetes!** 🚀

*Этот индекс обновляется при добавлении новых документов.*

