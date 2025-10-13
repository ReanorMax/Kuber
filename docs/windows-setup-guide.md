# Настройка Kubernetes Learning Project на Windows 11

## Проблема с доступом к сервисам

Если у вас Windows 11 и не работает доступ к `https://grafana.local`, выполните следующие шаги:

## 🔧 Шаги решения проблемы

### 1. Запуск Minikube (ВАЖНО!)

```powershell
# Откройте PowerShell как администратор и выполните:
minikube start --driver=docker --memory=4096 --cpus=2
```

### 2. Правильная настройка файла hosts в Windows 11

**Путь к файлу hosts в Windows 11:**
```
C:\Windows\System32\drivers\etc\hosts
```

**Как редактировать:**
1. Откройте **Блокнот как Администратор**
2. Откройте файл `C:\Windows\System32\drivers\etc\hosts`
3. Добавьте строки:

```
# Kubernetes local services
192.168.49.2 grafana.local
192.168.49.2 prometheus.local
192.168.49.2 alertmanager.local
192.168.49.2 metrics-app.local
# End Kubernetes local services
```

4. Сохраните файл

### 3. Получение правильного IP Minikube

```powershell
# Узнать IP Minikube
minikube ip

# Проверить статус
minikube status
```

### 4. Альтернативные способы доступа

#### Способ 1: NodePort (всегда работает)
```
http://<minikube-ip>:31282  # Grafana
```

#### Способ 2: Port Forwarding (если Ingress не работает)
```bash
# В терминале WSL или Git Bash
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80 --address 0.0.0.0
```
Затем открывайте: `http://localhost:3000`

#### Способ 3: Minikube tunnel (для LoadBalancer)
```powershell
# В отдельном окне PowerShell как администратор
minikube tunnel
```

### 5. Проверка сетевых настроек

```powershell
# Проверить DNS резолвинг
nslookup grafana.local

# Проверить доступность IP
ping 192.168.49.2

# Проверить порты
telnet 192.168.49.2 31282
```

### 6. Если ничего не работает - используйте port-forward

**Grafana:**
```bash
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80 --address 0.0.0.0
```
Доступ: http://localhost:3000

**Prometheus:**
```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090 --address 0.0.0.0
```
Доступ: http://localhost:9090

**Alertmanager:**
```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-alertmanager 9093:9093 --address 0.0.0.0
```
Доступ: http://localhost:9093

## 🐛 Типичные проблемы Windows + Minikube

### Проблема 1: Minikube не запускается
**Решение:**
```powershell
# Удалить старый кластер
minikube delete

# Запустить заново
minikube start --driver=docker --memory=4096 --cpus=2

# Если Docker не работает, используйте Hyper-V
minikube start --driver=hyperv --memory=4096 --cpus=2
```

### Проблема 2: IP адрес изменился
```powershell
# Узнать новый IP
minikube ip

# Обновить файл hosts с новым IP
```

### Проблема 3: Ingress Controller не работает
```bash
# Включить Ingress addon
minikube addons enable ingress

# Проверить статус
kubectl get pods -n ingress-nginx
```

### Проблема 4: DNS не работает
**Временное решение - используйте прямой IP:**
- Вместо `https://grafana.local` → `http://192.168.49.2:31282`
- Вместо `https://prometheus.local` → `http://192.168.49.2:<nodeport>`

## 🎯 Быстрая диагностика

**Скрипт для проверки (PowerShell):**
```powershell
Write-Host "=== Диагностика Kubernetes на Windows ===" -ForegroundColor Green

# Проверка Minikube
Write-Host "`n1. Статус Minikube:" -ForegroundColor Yellow
minikube status

# Проверка IP
Write-Host "`n2. IP Minikube:" -ForegroundColor Yellow
$minikube_ip = minikube ip
Write-Host $minikube_ip

# Проверка подов
Write-Host "`n3. Поды мониторинга:" -ForegroundColor Yellow
kubectl get pods -n monitoring

# Проверка Ingress
Write-Host "`n4. Ingress правила:" -ForegroundColor Yellow
kubectl get ingress -n monitoring

# Проверка доступности порта
Write-Host "`n5. Тест подключения к NodePort:" -ForegroundColor Yellow
Test-NetConnection -ComputerName $minikube_ip -Port 31282
```

## 🚀 После исправления

Когда все заработает, у вас будет доступ к:

- **Grafana**: https://grafana.local или http://192.168.49.2:31282
  - Логин: admin / Пароль: admin123
- **Prometheus**: https://prometheus.local  
- **Alertmanager**: https://alertmanager.local

## 💡 Рекомендации для Windows

1. **Используйте WSL2** для лучшей совместимости с Linux-инструментами
2. **Docker Desktop** должен быть запущен
3. **Запускайте PowerShell как администратор** для сетевых операций
4. **Отключите антивирус** временно, если блокирует Docker/Minikube
5. **Используйте port-forward** как наиболее надежный способ доступа
