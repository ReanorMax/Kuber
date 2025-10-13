# PowerShell скрипт для настройки Kubernetes Learning на Windows 11

Write-Host "🚀 === Настройка Kubernetes Learning Project на Windows 11 ===" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green

# Проверка прав администратора
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ Этот скрипт должен запускаться от имени Администратора!" -ForegroundColor Red
    Write-Host "Перезапустите PowerShell как администратор и попробуйте снова." -ForegroundColor Yellow
    exit 1
}

Write-Host "`n📋 1. Проверка статуса Minikube..." -ForegroundColor Yellow
$minikube_status = minikube status 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Minikube запущен" -ForegroundColor Green
    $minikube_ip = minikube ip
    Write-Host "IP Minikube: $minikube_ip" -ForegroundColor Cyan
} else {
    Write-Host "⚠️  Minikube остановлен. Запускаю..." -ForegroundColor Yellow
    Write-Host "Это может занять несколько минут..." -ForegroundColor Cyan
    minikube start --driver=docker --memory=4096 --cpus=2
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Minikube успешно запущен!" -ForegroundColor Green
        $minikube_ip = minikube ip
        Write-Host "IP Minikube: $minikube_ip" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Ошибка запуска Minikube. Попробуйте:" -ForegroundColor Red
        Write-Host "  minikube delete" -ForegroundColor Yellow
        Write-Host "  minikube start --driver=docker" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host "`n📋 2. Проверка Ingress Controller..." -ForegroundColor Yellow
$ingress_enabled = minikube addons list | Select-String "ingress.*enabled"
if ($ingress_enabled) {
    Write-Host "✅ Ingress Controller включен" -ForegroundColor Green
} else {
    Write-Host "⚠️  Включаю Ingress Controller..." -ForegroundColor Yellow
    minikube addons enable ingress
    Write-Host "✅ Ingress Controller включен" -ForegroundColor Green
}

Write-Host "`n📋 3. Настройка файла hosts..." -ForegroundColor Yellow
$hostsPath = "C:\Windows\System32\drivers\etc\hosts"
$hostsContent = Get-Content $hostsPath -ErrorAction SilentlyContinue

# Проверяем есть ли уже записи Kubernetes
$kubernetesEntries = $hostsContent | Select-String "grafana.local"

if ($kubernetesEntries) {
    Write-Host "⚠️  Обновляю существующие записи..." -ForegroundColor Yellow
    # Удаляем старые записи Kubernetes
    $newContent = $hostsContent | Where-Object { $_ -notmatch "grafana.local|prometheus.local|alertmanager.local|metrics-app.local" }
} else {
    $newContent = $hostsContent
    Write-Host "➕ Добавляю новые записи..." -ForegroundColor Yellow
}

# Добавляем новые записи
$kubernetesHosts = @(
    "",
    "# Kubernetes local services", 
    "$minikube_ip grafana.local",
    "$minikube_ip prometheus.local", 
    "$minikube_ip alertmanager.local",
    "$minikube_ip metrics-app.local",
    "# End Kubernetes local services"
)

$finalContent = $newContent + $kubernetesHosts

try {
    $finalContent | Out-File -FilePath $hostsPath -Encoding ASCII
    Write-Host "✅ Файл hosts обновлен!" -ForegroundColor Green
} catch {
    Write-Host "❌ Ошибка записи в файл hosts: $_" -ForegroundColor Red
    Write-Host "Попробуйте запустить PowerShell как администратор" -ForegroundColor Yellow
}

Write-Host "`n📋 4. Проверка статуса сервисов..." -ForegroundColor Yellow
$pods = kubectl get pods -n monitoring --no-headers 2>$null
if ($pods) {
    $runningPods = ($pods -split "`n" | Where-Object { $_ -match "Running" }).Count
    $totalPods = ($pods -split "`n").Count
    Write-Host "✅ Поды мониторинга: $runningPods/$totalPods запущены" -ForegroundColor Green
} else {
    Write-Host "⚠️  Поды мониторинга не найдены. Возможно нужно развернуть мониторинг стек." -ForegroundColor Yellow
}

Write-Host "`n📋 5. Тестирование подключений..." -ForegroundColor Yellow

# Тест NodePort для Grafana
Write-Host "Тестирую Grafana NodePort (31282)..." -ForegroundColor Cyan
$grafanaTest = Test-NetConnection -ComputerName $minikube_ip -Port 31282 -WarningAction SilentlyContinue
if ($grafanaTest.TcpTestSucceeded) {
    Write-Host "✅ Grafana NodePort доступен: http://$minikube_ip:31282" -ForegroundColor Green
} else {
    Write-Host "❌ Grafana NodePort недоступен" -ForegroundColor Red
}

# Тест DNS резолвинга
Write-Host "Тестирую DNS резолвинг..." -ForegroundColor Cyan
try {
    $dnsTest = Resolve-DnsName -Name "grafana.local" -ErrorAction Stop
    Write-Host "✅ DNS резолвинг работает: grafana.local -> $($dnsTest.IPAddress)" -ForegroundColor Green
} catch {
    Write-Host "⚠️  DNS резолвинг не работает, используйте прямой IP" -ForegroundColor Yellow
}

Write-Host "`n🎯 === Результаты настройки ===" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green

Write-Host "`n📊 Доступ к сервисам:" -ForegroundColor White
Write-Host "  • Grafana (DNS):     https://grafana.local" -ForegroundColor Cyan
Write-Host "  • Grafana (Direct):  http://$minikube_ip:31282" -ForegroundColor Cyan
Write-Host "  • Prometheus (DNS):  https://prometheus.local" -ForegroundColor Cyan
Write-Host "  • Alertmanager (DNS): https://alertmanager.local" -ForegroundColor Cyan
Write-Host "`n🔑 Логин Grafana: admin / Пароль: admin123" -ForegroundColor Yellow

Write-Host "`n🛠️  Полезные команды:" -ForegroundColor White
Write-Host "  minikube status                    # Статус кластера" -ForegroundColor Gray
Write-Host "  minikube ip                       # IP адрес кластера" -ForegroundColor Gray
Write-Host "  kubectl get pods -n monitoring    # Статус подов" -ForegroundColor Gray
Write-Host "  minikube dashboard                # Web UI кластера" -ForegroundColor Gray

Write-Host "`n🔧 Если что-то не работает:" -ForegroundColor White
Write-Host "  1. Перезапустите Minikube:       minikube stop && minikube start" -ForegroundColor Gray
Write-Host "  2. Используйте port-forward:     kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80" -ForegroundColor Gray
Write-Host "  3. Проверьте антивирус/файрвол" -ForegroundColor Gray

Write-Host "`n✅ Настройка завершена! Попробуйте открыть Grafana в браузере." -ForegroundColor Green

# Предложение открыть браузер
$openBrowser = Read-Host "`nОткрыть Grafana в браузере? (y/n)"
if ($openBrowser -eq 'y' -or $openBrowser -eq 'Y' -or $openBrowser -eq '') {
    Write-Host "Открываю браузер..." -ForegroundColor Cyan
    Start-Process "http://$minikube_ip:31282"
}
