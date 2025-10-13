#!/bin/bash
# Скрипт для установки примеров кастомного мониторинга

set -e

echo "🎯 === Установка примеров мониторинга ==="
echo "========================================"

# Проверяем что мы в правильной директории
if [ ! -f "README.md" ] || [ ! -d "manifests" ]; then
    echo "❌ Запустите скрипт из корня проекта kubernetes-learning/"
    exit 1
fi

echo ""
echo "📋 1. Применение примера приложения с метриками..."
kubectl apply -f manifests/apps/example-app-with-metrics.yaml

echo ""
echo "📊 2. Настройка ServiceMonitor для автоматического discovery..."
kubectl apply -f manifests/monitoring/custom-servicemonitor.yaml

echo ""
echo "🚨 3. Применение кастомных алертов..."
kubectl apply -f manifests/monitoring/custom-alerts.yaml

echo ""
echo "📈 4. Загрузка дашбордов в Grafana..."
kubectl apply -f manifests/monitoring/grafana-dashboards-configmap.yaml

echo ""
echo "🌐 5. Добавление DNS записи для example app..."
MINIKUBE_IP=$(minikube ip 2>/dev/null || kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

if [ -n "$MINIKUBE_IP" ]; then
    # Проверяем есть ли уже запись
    if ! grep -q "metrics-app.local" /etc/hosts; then
        echo "$MINIKUBE_IP metrics-app.local" | sudo tee -a /etc/hosts
        echo "✅ Добавлена DNS запись: $MINIKUBE_IP metrics-app.local"
    else
        echo "✅ DNS запись для metrics-app.local уже существует"
    fi
else
    echo "⚠️  Не удалось получить IP кластера"
fi

echo ""
echo "⏱️  6. Ожидание запуска сервисов..."
echo "Проверка статуса example приложения..."
kubectl wait --for=condition=available deployment/example-metrics-app --timeout=120s

echo ""
echo "🔍 7. Проверка статуса развертывания..."

echo "Статус подов:"
kubectl get pods -l app=example-metrics-app

echo ""
echo "Статус сервисов:"
kubectl get svc example-metrics-app-service

echo ""
echo "Статус Ingress:"
kubectl get ingress example-metrics-app-ingress

echo ""
echo "ServiceMonitors:"
kubectl get servicemonitors -A | grep -E "(NAME|example|custom)" || echo "ServiceMonitors не найдены"

echo ""
echo "PrometheusRules:"
kubectl get prometheusrules -A | grep -E "(NAME|custom)" || echo "PrometheusRules не найдены"

echo ""
echo "🎯 8. Тестирование доступности..."

echo "Тестирование example приложения:"
if curl -s --connect-timeout 5 http://metrics-app.local > /dev/null; then
    echo "✅ Example приложение доступно: http://metrics-app.local"
else
    echo "⚠️  Example приложение пока недоступно (может потребоваться время на запуск)"
fi

echo ""
echo "Тестирование метрик endpoint:"
METRICS_URL="http://$MINIKUBE_IP:$(kubectl get svc example-metrics-app-service -o jsonpath='{.spec.ports[?(@.name=="metrics")].nodePort}' 2>/dev/null || echo '9100')/metrics"
if curl -s --connect-timeout 5 "$METRICS_URL" | head -5 > /dev/null 2>&1; then
    echo "✅ Метрики доступны: $METRICS_URL"
else
    echo "⚠️  Метрики пока недоступны"
fi

echo ""
echo "📋 9. Инструкции по использованию..."

echo ""
echo "🎯 Доступные сервисы:"
echo "  • Example App:     http://metrics-app.local"
echo "  • Grafana:         https://grafana.local (admin/admin123)"
echo "  • Prometheus:      https://prometheus.local"
echo "  • Alertmanager:    https://alertmanager.local"

echo ""
echo "📊 Что проверить в Prometheus (https://prometheus.local):"
echo "  1. Status → Targets - должен появиться target example-metrics-app-monitor"
echo "  2. Status → Rules - должны появиться кастомные алерты"
echo "  3. Alerts - через время появятся активные алерты (если есть проблемы)"
echo ""
echo "Примеры PromQL запросов:"
echo "  • up{job=\"example-metrics-app-monitor\"}"
echo "  • node_memory_MemAvailable_bytes"
echo "  • rate(node_network_receive_bytes_total[5m])"

echo ""
echo "📈 Что проверить в Grafana (https://grafana.local):"
echo "  1. Перейдите в Dashboards → Browse"
echo "  2. Найдите папку с кастомными дашбордами"
echo "  3. Откройте 'Kubernetes Cluster Overview - Learning'"
echo "  4. Откройте 'Learning Dashboard - First Steps' для изучения PromQL"

echo ""
echo "🧪 Практические упражнения:"
echo "  1. Создайте нагрузку на example приложение:"
echo "     while true; do curl http://metrics-app.local; sleep 1; done"
echo ""
echo "  2. Наблюдайте метрики в Prometheus и Grafana"
echo ""
echo "  3. Создайте собственный дашборд с метриками node_exporter"
echo ""
echo "  4. Настройте алерт на высокое потребление CPU"

echo ""
echo "🛠️  Полезные команды для диагностики:"
echo "  kubectl logs -l app=example-metrics-app"
echo "  kubectl describe servicemonitor example-metrics-app-monitor"
echo "  kubectl get prometheusrules custom-application-alerts -o yaml"
echo "  ./scripts/diagnose-app.sh example-metrics-app default"

echo ""
echo "✅ Установка примеров мониторинга завершена!"
echo ""
echo "📚 Для изучения откройте:"
echo "  • docs/learning-guide-02-networking-monitoring.md"
echo "  • docs/learning-guide-03-advanced-topics.md"
echo ""
echo "🎉 Удачного изучения Kubernetes и мониторинга!"
