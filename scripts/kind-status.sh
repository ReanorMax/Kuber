#!/bin/bash
# Скрипт для проверки статуса Kind кластера

echo "🔍 Kind Cluster Status"
echo "====================="
echo "Время проверки: $(date)"
echo ""

# Проверяем что Kind кластер существует
if ! kind get clusters | grep -q learning-cluster; then
    echo "❌ Kind кластер 'learning-cluster' не найден!"
    echo "Создайте кластер: kind create cluster --config=kind-config.yaml --name=learning-cluster"
    exit 1
fi

echo "📊 Cluster Info:"
kubectl cluster-info --context kind-learning-cluster

echo ""
echo "🖥️ Nodes:"
kubectl get nodes -o wide

echo ""
echo "🐳 Kind Containers:"
docker ps --filter "name=learning-cluster"

echo ""
echo "📦 Monitoring Pods:"
kubectl get pods -n monitoring

echo ""
echo "🌐 NodePort Services:"
kubectl get svc -n monitoring | grep NodePort

echo ""
echo "🔗 Ingress Status:"
kubectl get ingress -A

echo ""
echo "📈 Resource Usage:"
if kubectl top nodes &>/dev/null; then
    kubectl top nodes
    echo ""
    kubectl top pods -n monitoring
else
    echo "⚠️ Metrics server недоступен"
fi

echo ""
echo "🎯 Access URLs:"
EXTERNAL_IP=$(hostname -I | awk '{print $1}')
echo "  📊 Grafana:      http://$EXTERNAL_IP:3000 (admin/admin123)"
echo "  📊 Grafana:      http://localhost:3000"
echo "  📈 Prometheus:   http://$EXTERNAL_IP:9090"
echo "  📈 Prometheus:   http://localhost:9090"
echo "  🚨 Alertmanager: http://$EXTERNAL_IP:9093"
echo "  🚨 Alertmanager: http://localhost:9093"

echo ""
echo "🧪 Quick Health Tests:"

# Тест доступности Grafana
if curl -s --connect-timeout 3 http://localhost:3000 > /dev/null; then
    echo "✅ Grafana доступна"
else
    echo "❌ Grafana недоступна"
fi

# Тест доступности Prometheus
if curl -s --connect-timeout 3 http://localhost:9090 > /dev/null; then
    echo "✅ Prometheus доступен"
else
    echo "❌ Prometheus недоступен"
fi

# Тест доступности Alertmanager
if curl -s --connect-timeout 3 http://localhost:9093 > /dev/null; then
    echo "✅ Alertmanager доступен"
else
    echo "❌ Alertmanager недоступен"
fi

echo ""
echo "📋 Management Commands:"
echo "  kind get clusters                    # Список кластеров"
echo "  kubectl config get-contexts         # Доступные контексты"
echo "  kubectl get all -A                  # Все ресурсы"
echo "  ./scripts/daily-check.sh            # Подробная проверка"
echo "  ./scripts/kind-backup.sh            # Создать backup"

echo ""
echo "🔧 If Issues Found:"
echo "  kubectl get events --sort-by='.lastTimestamp' -A"
echo "  kubectl logs -n monitoring deployment/prometheus-grafana"
echo "  docker logs learning-cluster-control-plane"
