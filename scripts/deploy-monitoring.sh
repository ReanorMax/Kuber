#!/bin/bash
# Скрипт для развертывания мониторинга с улучшенной конфигурацией

set -e

NAMESPACE="monitoring"
HELM_RELEASE="prometheus"

echo "🚀 Развертывание улучшенного мониторинга стека..."

# Проверяем наличие namespace
if ! kubectl get namespace $NAMESPACE &> /dev/null; then
    echo "📦 Создание namespace $NAMESPACE..."
    kubectl create namespace $NAMESPACE
fi

# Добавляем Helm репозиторий если не добавлен
echo "📋 Проверка Helm репозитория..."
if ! helm repo list | grep -q prometheus-community; then
    echo "➕ Добавление prometheus-community репозитория..."
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
fi

# Обновляем репозиторий
echo "🔄 Обновление Helm репозитория..."
helm repo update

# Проверяем существующую установку
if helm list -n $NAMESPACE | grep -q $HELM_RELEASE; then
    echo "⬆️ Обновление существующей установки..."
    helm upgrade $HELM_RELEASE prometheus-community/kube-prometheus-stack \
        -n $NAMESPACE \
        -f ../helm-values/custom-prometheus-values.yaml \
        --wait --timeout=10m
else
    echo "🆕 Установка нового мониторинга стека..."
    helm install $HELM_RELEASE prometheus-community/kube-prometheus-stack \
        -n $NAMESPACE \
        -f ../helm-values/custom-prometheus-values.yaml \
        --wait --timeout=10m
fi

echo "✅ Развертывание завершено!"

# Показываем статус развертывания
echo "📊 Статус подов:"
kubectl get pods -n $NAMESPACE

echo "🌐 Доступные сервисы:"
kubectl get svc -n $NAMESPACE

echo "🔗 Ingress правила:"
kubectl get ingress -n $NAMESPACE

echo ""
echo "🎯 Доступ к сервисам:"
echo "  Grafana:      http://grafana.local (или http://$(minikube ip):31282)"
echo "  Prometheus:   http://prometheus.local"  
echo "  Alertmanager: http://alertmanager.local"
echo ""
echo "⚠️  Не забудьте добавить записи в /etc/hosts:"
echo "  $(minikube ip) grafana.local prometheus.local alertmanager.local"
