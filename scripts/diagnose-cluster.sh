#!/bin/bash
# Скрипт комплексной диагностики Kubernetes кластера

set -e

echo "🔍 === Kubernetes Cluster Diagnostics ==="
echo "Время запуска: $(date)"
echo "Пользователь: $(whoami)"
echo "==========================================="

echo ""
echo "📊 1. Cluster Info:"
kubectl cluster-info

echo ""
echo "🖥️  2. Node Status:"
kubectl get nodes -o wide

echo ""
echo "⚙️  3. System Pods:"
kubectl get pods -n kube-system --sort-by=.metadata.creationTimestamp

echo ""
echo "📈 4. Resource Usage (Top 10):"
if kubectl top nodes &>/dev/null; then
    echo "Узлы:"
    kubectl top nodes
    echo ""
    echo "Pod'ы (по памяти):"
    kubectl top pods -A --sort-by=memory | head -10
else
    echo "⚠️  Metrics server недоступен"
fi

echo ""
echo "🚨 5. Recent Events (last 20):"
kubectl get events --sort-by='.lastTimestamp' -A | head -20

echo ""
echo "❌ 6. Failed Pods:"
FAILED_PODS=$(kubectl get pods -A --field-selector=status.phase=Failed --no-headers 2>/dev/null | wc -l)
if [ "$FAILED_PODS" -gt 0 ]; then
    kubectl get pods -A --field-selector=status.phase=Failed
else
    echo "✅ Нет failed подов"
fi

echo ""
echo "🔄 7. Pods with High Restart Count (>5):"
kubectl get pods -A -o json | jq -r '.items[] | select(.status.containerStatuses[]?.restartCount > 5) | "\(.metadata.namespace)/\(.metadata.name) - Restarts: \(.status.containerStatuses[0].restartCount)"' 2>/dev/null || echo "✅ Нет подов с высоким количеством перезапусков"

echo ""
echo "🌐 8. Networking Status:"
echo "Services:"
kubectl get svc -A | grep -E "(LoadBalancer|NodePort)" || echo "Только ClusterIP сервисы"
echo ""
echo "Ingress:"
kubectl get ingress -A

echo ""
echo "💾 9. Storage Status:"
echo "PV:"
kubectl get pv 2>/dev/null || echo "Нет PV"
echo ""
echo "PVC:"
kubectl get pvc -A 2>/dev/null || echo "Нет PVC"

echo ""
echo "🔗 10. Services without Endpoints:"
NO_ENDPOINTS_FOUND=false
for ns in $(kubectl get ns -o jsonpath='{.items[*].metadata.name}'); do
    EMPTY_ENDPOINTS=$(kubectl get endpoints -n $ns -o json 2>/dev/null | jq -r '.items[] | select(.subsets == null or .subsets == []) | "\(.metadata.namespace)/\(.metadata.name)"' 2>/dev/null)
    if [ -n "$EMPTY_ENDPOINTS" ]; then
        echo "$EMPTY_ENDPOINTS"
        NO_ENDPOINTS_FOUND=true
    fi
done
if [ "$NO_ENDPOINTS_FOUND" = false ]; then
    echo "✅ Все сервисы имеют endpoints"
fi

echo ""
echo "🛡️  11. Security Status:"
echo "ServiceAccounts без automountServiceAccountToken:"
kubectl get serviceaccounts -A -o json | jq -r '.items[] | select(.automountServiceAccountToken == false) | "\(.metadata.namespace)/\(.metadata.name)"' 2>/dev/null || echo "Все SA с automount"

echo ""
echo "NetworkPolicies:"
NETPOL_COUNT=$(kubectl get networkpolicy -A --no-headers 2>/dev/null | wc -l)
if [ "$NETPOL_COUNT" -gt 0 ]; then
    kubectl get networkpolicy -A
else
    echo "⚠️  Network Policies не настроены"
fi

echo ""
echo "🔍 12. Monitoring Stack Status:"
if kubectl get namespace monitoring &>/dev/null; then
    echo "Prometheus Stack:"
    kubectl get pods -n monitoring -o wide
    echo ""
    echo "Ingress для мониторинга:"
    kubectl get ingress -n monitoring
else
    echo "⚠️  Namespace monitoring не найден"
fi

echo ""
echo "📊 13. Cluster Summary:"
TOTAL_NODES=$(kubectl get nodes --no-headers | wc -l)
READY_NODES=$(kubectl get nodes --no-headers | grep -c "Ready")
TOTAL_PODS=$(kubectl get pods -A --no-headers | wc -l)
RUNNING_PODS=$(kubectl get pods -A --no-headers | grep -c "Running")
TOTAL_SERVICES=$(kubectl get svc -A --no-headers | wc -l)

echo "Узлы: $READY_NODES/$TOTAL_NODES готовы"
echo "Pod'ы: $RUNNING_PODS/$TOTAL_PODS запущены"
echo "Сервисы: $TOTAL_SERVICES"
echo "Namespaces: $(kubectl get ns --no-headers | wc -l)"

echo ""
echo "✅ Диагностика завершена!"
echo "Время завершения: $(date)"

# Опционально сохраняем отчет в файл
if [ "$1" = "--save" ]; then
    REPORT_FILE="cluster-diagnostics-$(date +%Y%m%d_%H%M%S).log"
    $0 > "$REPORT_FILE" 2>&1
    echo "📝 Отчет сохранен в: $REPORT_FILE"
fi
