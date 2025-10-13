#!/bin/bash
# Ежедневная проверка здоровья Kind кластера

echo "📅 Ежедневная проверка Kind кластера - $(date)"
echo "================================================="

# Функция для цветного вывода
print_status() {
    if [ "$1" = "OK" ]; then
        echo "✅ $2"
    elif [ "$1" = "WARN" ]; then
        echo "⚠️ $2"
    else
        echo "❌ $2"
    fi
}

# Проверка существования кластера
if ! kind get clusters | grep -q learning-cluster; then
    print_status "ERROR" "Kind кластер 'learning-cluster' не найден!"
    echo "Создайте кластер: ./scripts/migrate-to-kind.sh"
    exit 1
fi

echo "1. 🖥️ Node Health:"
NODE_STATUS=$(kubectl get nodes --no-headers | awk '{print $2}')
if [ "$NODE_STATUS" = "Ready" ]; then
    print_status "OK" "Узел кластера готов"
    kubectl get nodes
else
    print_status "ERROR" "Узел кластера не готов: $NODE_STATUS"
fi

echo ""
echo "2. 📦 Pod Health Check:"
TOTAL_MONITORING_PODS=$(kubectl get pods -n monitoring --no-headers | wc -l)
RUNNING_MONITORING_PODS=$(kubectl get pods -n monitoring --no-headers | grep -c "Running")

if [ "$RUNNING_MONITORING_PODS" -eq "$TOTAL_MONITORING_PODS" ]; then
    print_status "OK" "Все поды мониторинга работают ($RUNNING_MONITORING_PODS/$TOTAL_MONITORING_PODS)"
else
    print_status "WARN" "Некоторые поды мониторинга не работают ($RUNNING_MONITORING_PODS/$TOTAL_MONITORING_PODS)"
    kubectl get pods -n monitoring | grep -v "Running"
fi

# Проверяем системные поды
FAILED_SYSTEM_PODS=$(kubectl get pods -A --field-selector=status.phase=Failed --no-headers | wc -l)
if [ "$FAILED_SYSTEM_PODS" -gt 0 ]; then
    print_status "WARN" "Обнаружены failed поды: $FAILED_SYSTEM_PODS"
    kubectl get pods -A --field-selector=status.phase=Failed
else
    print_status "OK" "Нет failed подов"
fi

echo ""
echo "3. 🌐 Service Accessibility:"

# Тест Grafana
GRAFANA_TEST=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 http://localhost:3000 || echo "000")
if [ "$GRAFANA_TEST" = "200" ] || [ "$GRAFANA_TEST" = "302" ]; then
    print_status "OK" "Grafana доступна (HTTP $GRAFANA_TEST)"
else
    print_status "ERROR" "Grafana недоступна (HTTP $GRAFANA_TEST)"
fi

# Тест Prometheus
PROMETHEUS_TEST=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 http://localhost:9090 || echo "000")
if [ "$PROMETHEUS_TEST" = "200" ]; then
    print_status "OK" "Prometheus доступен (HTTP $PROMETHEUS_TEST)"
else
    print_status "ERROR" "Prometheus недоступен (HTTP $PROMETHEUS_TEST)"
fi

# Тест Alertmanager
ALERTMANAGER_TEST=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 http://localhost:9093 || echo "000")
if [ "$ALERTMANAGER_TEST" = "200" ]; then
    print_status "OK" "Alertmanager доступен (HTTP $ALERTMANAGER_TEST)"
else
    print_status "ERROR" "Alertmanager недоступен (HTTP $ALERTMANAGER_TEST)"
fi

echo ""
echo "4. 📊 Resource Usage:"
if kubectl top nodes &>/dev/null; then
    echo "CPU и Memory по узлам:"
    kubectl top nodes
    
    echo ""
    echo "Top 5 подов по потреблению памяти:"
    kubectl top pods -A --sort-by=memory | head -6
    
    echo ""
    echo "Top 5 подов по потреблению CPU:"
    kubectl top pods -A --sort-by=cpu | head -6
else
    print_status "WARN" "Metrics server недоступен"
fi

echo ""
echo "5. 💾 Storage Health:"
PVC_COUNT=$(kubectl get pvc -A --no-headers | wc -l)
if [ "$PVC_COUNT" -gt 0 ]; then
    echo "PersistentVolumeClaims:"
    kubectl get pvc -A
else
    print_status "OK" "Нет PVC (ожидаемо для демо кластера)"
fi

echo ""
echo "6. 🛡️ Security Status:"
# Проверяем RBAC
CLUSTER_ROLES=$(kubectl get clusterroles --no-headers | wc -l)
echo "ClusterRoles: $CLUSTER_ROLES"

# Проверяем ServiceAccounts
SA_COUNT=$(kubectl get serviceaccounts -A --no-headers | wc -l)
echo "ServiceAccounts: $SA_COUNT"

echo ""
echo "7. 🔄 Recent Events (last 10):"
kubectl get events --sort-by='.lastTimestamp' -A | tail -10

echo ""
echo "8. 📈 Prometheus Targets Status:"
if curl -s http://localhost:9090/api/v1/targets 2>/dev/null | grep -q '"health":"up"'; then
    UP_TARGETS=$(curl -s http://localhost:9090/api/v1/targets 2>/dev/null | grep -o '"health":"up"' | wc -l)
    DOWN_TARGETS=$(curl -s http://localhost:9090/api/v1/targets 2>/dev/null | grep -o '"health":"down"' | wc -l)
    print_status "OK" "Prometheus targets: $UP_TARGETS up, $DOWN_TARGETS down"
else
    print_status "WARN" "Не удалось получить статус Prometheus targets"
fi

echo ""
echo "9. 🚨 Active Alerts:"
if curl -s http://localhost:9093/api/v1/alerts 2>/dev/null | grep -q '"status":"firing"'; then
    FIRING_ALERTS=$(curl -s http://localhost:9093/api/v1/alerts 2>/dev/null | grep -o '"status":"firing"' | wc -l)
    print_status "WARN" "Активных алертов: $FIRING_ALERTS"
else
    print_status "OK" "Нет активных алертов"
fi

echo ""
echo "📋 Summary:"
echo "================================================="
EXTERNAL_IP=$(hostname -I | awk '{print $1}')
echo "🌟 Кластер: kind-learning-cluster"
echo "🖥️ Узлов: 1 (Ready)"  
echo "📦 Подов мониторинга: $RUNNING_MONITORING_PODS/$TOTAL_MONITORING_PODS"
echo "🌐 Внешний доступ: http://$EXTERNAL_IP:3000"

if [ "$RUNNING_MONITORING_PODS" -eq "$TOTAL_MONITORING_PODS" ] && 
   [ "$GRAFANA_TEST" = "200" -o "$GRAFANA_TEST" = "302" ] && 
   [ "$PROMETHEUS_TEST" = "200" ]; then
    print_status "OK" "Кластер полностью работоспособен!"
else
    print_status "WARN" "Обнаружены проблемы, требуется внимание"
fi

echo ""
echo "🔧 Quick fixes if needed:"
echo "  kubectl rollout restart deployment -n monitoring   # Перезапуск мониторинга"
echo "  kind delete cluster --name=learning-cluster       # Полная пересборка"
echo "  ./scripts/migrate-to-kind.sh                      # Автоматическое восстановление"

echo ""
echo "Проверка завершена: $(date)"
