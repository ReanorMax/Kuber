#!/bin/bash
# Скрипт для отображения полной информации о кластере и мониторинге

set -e

echo "🔍 Информация о Kubernetes кластере"
echo "=================================="

# Основная информация о кластере
echo "📊 Статус кластера:"
kubectl cluster-info

echo ""
echo "🖥️ Узлы кластера:"
kubectl get nodes -o wide

echo ""
echo "📦 Namespaces:"
kubectl get namespaces

echo ""
echo "🏃 Поды в namespace monitoring:"
kubectl get pods -n monitoring -o wide

echo ""
echo "🌐 Сервисы в namespace monitoring:"
kubectl get svc -n monitoring

echo ""
echo "🔗 Ingress правила:"
kubectl get ingress -A

echo ""
echo "💾 PersistentVolumes:"
kubectl get pv

echo ""
echo "📈 Использование ресурсов (если metrics-server установлен):"
if kubectl get deployment metrics-server -n kube-system &> /dev/null; then
    kubectl top nodes
    echo ""
    kubectl top pods -n monitoring
else
    echo "⚠️  metrics-server не установлен - статистика ресурсов недоступна"
fi

echo ""
echo "🎯 Быстрый доступ к сервисам:"
MINIKUBE_IP=$(minikube ip 2>/dev/null || echo "N/A")

if [ "$MINIKUBE_IP" != "N/A" ]; then
    echo "  Minikube IP: $MINIKUBE_IP"
    echo "  Grafana (NodePort):    http://$MINIKUBE_IP:31282"
    echo "  Grafana (Ingress):     http://grafana.local"
    echo "  Prometheus (Ingress):  http://prometheus.local"
    echo "  Alertmanager (Ingress): http://alertmanager.local"
    echo ""
    echo "  Port-forward команды для прямого доступа:"
    echo "    kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090"
    echo "    kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-alertmanager 9093:9093"
    echo "    kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
else
    echo "⚠️  Minikube не запущен или недоступен"
fi

echo ""
echo "🔧 Полезные команды:"
echo "  kubectl get all -n monitoring                    # Все ресурсы мониторинга"
echo "  kubectl logs -n monitoring deployment/prometheus-grafana -f  # Логи Grafana"
echo "  helm list -n monitoring                         # Helm релизы"
echo "  minikube dashboard                              # Web UI кластера"

echo ""
echo "📚 Файлы конфигурации проекта:"
echo "  helm-values/custom-prometheus-values.yaml      # Кастомные значения Helm"
echo "  manifests/                                      # Экспортированные манифесты"
echo "  docs/                                          # Документация архитектуры"
