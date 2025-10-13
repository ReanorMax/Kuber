# 🔧 Troubleshooting Guide - Решение проблем Kubernetes

> 📚 **Навигация**: [← Назад к INDEX](INDEX.md) | [🏠 Главная](../README.md)


## 📋 Обзор

Этот документ содержит все проблемы, с которыми мы столкнулись при настройке Kubernetes Learning Environment, и способы их решения. Используйте его для обучения и решения аналогичных проблем.

---

## 🚨 Проблема 1: Высокая нагрузка на сервер

### 🔍 **Симптомы**:
- Память: 3.7GB из 3.8GB (98% использовано)
- Swap: 974MB полностью заполнен
- Медленная работа всех сервисов
- Grafana показывает ошибки health check'ов

### 🔍 **Диагностика**:
```bash
# Проверка памяти
free -h

# Проверка Docker контейнеров
docker stats --no-stream

# Результат:
# Kind кластер: 1.575GB памяти
# Minikube кластер: 1.45GB памяти
# Итого: ~3GB только на Kubernetes кластеры!
```

### ✅ **Решение**:
1. **Остановили Minikube**:
   ```bash
   minikube stop
   docker rm -f minikube
   ```

2. **Удалили Minikube полностью**:
   ```bash
   docker volume rm minikube
   docker rmi gcr.io/k8s-minikube/kicbase:v0.0.48
   rm -rf ~/.minikube
   docker system prune -f
   ```

3. **Результат**:
   - Память: 2.4GB/3.8GB (63% использовано) ✅
   - Диск: с 16GB до 11GB (освобождено ~5GB) ✅
   - Только Kind кластер: 1.8GB памяти ✅

### 📚 **Урок**:
- **Не запускайте несколько кластеров одновременно** на слабом сервере
- **Мониторьте ресурсы**: `free -h`, `docker stats`
- **Останавливайте неиспользуемые сервисы**

---

## 🚨 Проблема 2: Grafana Health Check Failures

### 🔍 **Симптомы**:
```
Events:
  Type     Reason     Age                   From     Message
  ----     ------     ----                  ----     -------
  Warning  Unhealthy  60m                   kubelet  Liveness probe failed: Get "http://10.244.0.10:3000/api/health": context deadline exceeded
  Warning  Unhealthy  49m (x5 over 60m)     kubelet  Liveness probe failed: HTTP probe failed with statuscode: 503
  Warning  Unhealthy  5m45s (x84 over 60m)  kubelet  Readiness probe failed: Get "http://10.244.0.10:3000/api/health": context deadline exceeded
```

### 🔍 **Диагностика**:
```bash
# Проверка логов Grafana
kubectl logs prometheus-grafana-7698c6449c-7x9x8 -n monitoring -c grafana --tail=20

# Результат: постоянные ошибки загрузки дашбордов
# "Dashboard title cannot be empty"
```

### ✅ **Решение**:
1. **Увеличили таймауты health check'ов**:
   ```bash
   kubectl patch deployment prometheus-grafana -n monitoring -p '{"spec":{"template":{"spec":{"containers":[{"name":"grafana","livenessProbe":{"timeoutSeconds":60,"periodSeconds":30},"readinessProbe":{"timeoutSeconds":30,"periodSeconds":15}}]}}}}'
   ```

2. **Удалили проблемные дашборды**:
   ```bash
   kubectl delete configmap custom-dashboards -n monitoring
   ```

3. **Перезапустили Grafana**:
   ```bash
   kubectl rollout restart deployment prometheus-grafana -n monitoring
   kubectl rollout status deployment prometheus-grafana -n monitoring
   ```

4. **Проверили результат**:
   ```bash
   curl -s http://10.19.1.209:3000/api/health
   # {"database": "ok", "version": "12.2.0", "commit": "..."}
   ```

### 📚 **Урок**:
- **Health check'и должны учитывать нагрузку** на сервер
- **Проблемные конфигурации** создают дополнительную нагрузку
- **Мониторьте логи** для выявления проблем

---

## 🚨 Проблема 3: Kubernetes Dashboard - неактивная кнопка Sign In

### 🔍 **Симптомы**:
- Dashboard открывается, но кнопка "Sign in" неактивна
- Предупреждение: "Insecure access detected. Sign in will not be available"

### 🔍 **Диагностика**:
- Dashboard блокирует HTTP доступ из соображений безопасности
- Нужен HTTPS доступ или localhost

### ✅ **Решение**:
1. **Создали SSH туннель** (рекомендуется):
   ```bash
   # На Windows (PowerShell)
   ssh -L 8001:127.0.0.1:8001 root@10.19.1.209 -N
   
   # На сервере
   kubectl proxy --address=127.0.0.1 --port=8001
   
   # URL: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
   ```

2. **Создали HTTPS Ingress** (альтернатива):
   ```bash
   # Создали SSL сертификат
   openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout dashboard.key -out dashboard.crt -subj "/CN=dashboard.local"
   
   # Создали TLS secret
   kubectl create secret tls dashboard-tls --cert=dashboard.crt --key=dashboard.key -n kubernetes-dashboard
   
   # Применили Ingress
   kubectl apply -f manifests/dashboard-ingress.yaml
   
   # URL: https://dashboard.local:8443
   ```

### 📚 **Урок**:
- **Dashboard требует безопасный доступ** (HTTPS или localhost)
- **SSH туннель** - самый простой способ
- **Ingress с SSL** - для production использования

---

## 🚨 Проблема 4: Dashboard показывает только 2 пода

### 🔍 **Симптомы**:
- В Dashboard видно только 2 пода из namespace `default`
- Не видно поды из `monitoring`, `demo-apps` и других namespace'ов

### 🔍 **Диагностика**:
```bash
# Проверка прав токена
kubectl auth can-i list pods --all-namespaces --as=system:serviceaccount:kubernetes-dashboard:admin-user
# yes - права есть

# Проверка подов в разных namespace'ах
kubectl get pods --all-namespaces | wc -l
# 25 подов всего
```

### ✅ **Решение**:
1. **Создали супер-админа**:
   ```bash
   kubectl apply -f manifests/dashboard-super-admin.yaml
   ```

2. **Сгенерировали новый токен**:
   ```bash
   kubectl -n kubernetes-dashboard create token dashboard-admin
   ```

3. **Объяснили переключение namespace'ов**:
   - В Dashboard найти селектор namespace (выпадающий список)
   - Выбрать нужный namespace: `monitoring`, `demo-apps`, etc.
   - Теперь видны все поды выбранного namespace'а

### 📚 **Урок**:
- **Dashboard по умолчанию показывает только `default`**
- **Нужно вручную переключаться** между namespace'ами
- **Права токена** должны быть достаточными

---

## 🚨 Проблема 5: Port-forward не работает

### 🔍 **Симптомы**:
```
error: Service kubernetes-dashboard does not have a service port 8443
```

### 🔍 **Диагностика**:
```bash
# Проверка портов пода
kubectl describe pod -n kubernetes-dashboard -l k8s-app=kubernetes-dashboard | grep "Port:"
# Port: 8443/TCP

# Проверка сервиса
kubectl get svc kubernetes-dashboard -n kubernetes-dashboard -o yaml
# ports: - port: 443, targetPort: 8443
```

### ✅ **Решение**:
```bash
# Правильный port-forward
kubectl port-forward -n kubernetes-dashboard svc/kubernetes-dashboard 9443:443 --address 0.0.0.0

# Или через kubectl proxy (рекомендуется)
kubectl proxy --address='0.0.0.0' --accept-hosts='.*' --port=8001
```

### 📚 **Урок**:
- **Проверяйте маппинг портов** в сервисах
- **kubectl proxy** более надежен чем port-forward
- **Используйте правильные порты** (443, а не 8443)

---

## 🌐 Доступ к сервисам

### 📊 **Grafana**:
- **URL**: http://10.19.1.209:3000
- **Логин**: admin
- **Пароль**: admin123
- **Статус**: ✅ Работает стабильно

### 📈 **Prometheus**:
- **URL**: http://10.19.1.209:9090
- **Статус**: ✅ Работает

### 🚨 **Alertmanager**:
- **URL**: http://10.19.1.209:9093
- **Статус**: ✅ Работает

### 🖥️ **Kubernetes Dashboard**:
- **URL**: http://10.19.1.209:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
- **Токен**: `kubectl -n kubernetes-dashboard create token dashboard-admin`
- **Статус**: ✅ Работает через kubectl proxy

### 💻 **Lens** (рекомендуется):
- **Скачать**: https://k8slens.dev/
- **Kubeconfig**: `kubeconfig-for-windows.yaml`
- **SSH туннель**: `ssh -L 6443:127.0.0.1:41917 root@10.19.1.209 -N`
- **Статус**: ✅ Готов к использованию

---

## 🛠️ Полезные команды для диагностики

### **Проверка ресурсов**:
```bash
# Память
free -h

# Диск
df -h

# Docker контейнеры
docker stats --no-stream

# Kubernetes поды
kubectl get pods --all-namespaces
```

### **Проверка логов**:
```bash
# Логи пода
kubectl logs <pod-name> -n <namespace>

# Логи контейнера
kubectl logs <pod-name> -c <container-name> -n <namespace>

# События пода
kubectl describe pod <pod-name> -n <namespace>
```

### **Проверка сервисов**:
```bash
# Статус сервисов
kubectl get svc --all-namespaces

# Детали сервиса
kubectl describe svc <service-name> -n <namespace>

# Проверка endpoints
kubectl get endpoints <service-name> -n <namespace>
```

### **Проверка Ingress**:
```bash
# Статус Ingress
kubectl get ingress --all-namespaces

# Детали Ingress
kubectl describe ingress <ingress-name> -n <namespace>
```

---

## 📚 Уроки для обучения

### **1. Мониторинг ресурсов**:
- Всегда проверяйте `free -h` и `docker stats`
- Не запускайте несколько тяжелых сервисов одновременно
- Останавливайте неиспользуемые контейнеры

### **2. Health Check'и**:
- Настраивайте реалистичные таймауты
- Учитывайте нагрузку на сервер
- Мониторьте логи для выявления проблем

### **3. Безопасность**:
- Dashboard требует HTTPS или localhost
- Используйте SSH туннели для безопасного доступа
- Настраивайте правильные права доступа

### **4. Namespace'ы**:
- Dashboard показывает только один namespace за раз
- Переключайтесь между namespace'ами вручную
- Используйте Lens для лучшего обзора

### **5. Troubleshooting**:
- Начинайте с логов: `kubectl logs`
- Проверяйте события: `kubectl describe`
- Используйте правильные команды диагностики

---

## 🎯 Рекомендации

### **Для обучения**:
1. **Начните с Lens** - он проще и быстрее
2. **Изучите kubectl** - основа всех операций
3. **Мониторьте ресурсы** - важный навык
4. **Читайте логи** - ключ к пониманию проблем

### **Для production**:
1. **Настройте мониторинг** ресурсов
2. **Используйте HTTPS** для всех сервисов
3. **Настройте RBAC** правильно
4. **Документируйте** все изменения

---

*Этот гайд поможет вам избежать типичных проблем и быстро решать возникающие вопросы при работе с Kubernetes.*

---

## 🔗 **Связанные документы**

### **Для решения конкретных проблем**:
- [📊 Prometheus Stack](prometheus-stack-components.md) - архитектура компонентов мониторинга
- [🌐 Проброс портов](port-forwarding-explained.md) - проблемы с доступом к сервисам
- [📦 Pod vs Container](pods-vs-containers-explained.md) - проблемы с Pod'ами
- [🔍 Переменные окружения](how-to-check-env-variables.md) - диагностика конфигурации

### **Базовая диагностика**:
- [🔧 Troubleshooting Guide](troubleshooting-guide.md) - скрипты диагностики
- [📖 Урок 1: Основы](learning-guide-01-basics.md) - базовые команды kubectl

### **Навигация**:
- [📚 Полный индекс документации](INDEX.md)
- [🏠 Главная страница](../README.md)
