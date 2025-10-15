#!/bin/bash

echo "🚀 Запуск всех сервисов для обучающей среды Kubernetes..."

# Функция для проверки что порт свободен
check_port() {
    local port=$1
    if netstat -tlnp | grep -q ":$port "; then
        echo "⚠️  Порт $port уже занят"
        return 1
    fi
    return 0
}

# Функция для запуска port-forward
start_port_forward() {
    local service=$1
    local namespace=$2
    local local_port=$3
    local remote_port=$4
    local name=$5
    
    echo "🔄 Запуск $name на порту $local_port..."
    
    if check_port $local_port; then
        kubectl port-forward -n $namespace svc/$service $local_port:$remote_port --address=0.0.0.0 &
        sleep 2
        if netstat -tlnp | grep -q ":$local_port "; then
            echo "✅ $name доступен на http://10.19.1.209:$local_port"
        else
            echo "❌ Ошибка запуска $name"
        fi
    fi
}

echo ""
echo "🔧 Запуск port-forward для сервисов..."

# ArgoCD
start_port_forward "argocd-server" "argocd" "30444" "80" "ArgoCD"

# Grafana (если не запущен через NodePort)
if ! netstat -tlnp | grep -q ":30300 "; then
    start_port_forward "grafana" "default" "30300" "80" "Grafana"
fi

# Prometheus (если установлен)
if kubectl get svc -n monitoring prometheus-kube-prometheus-prometheus >/dev/null 2>&1; then
    start_port_forward "prometheus-kube-prometheus-prometheus" "monitoring" "30090" "9090" "Prometheus"
fi

# Alertmanager (если установлен)
if kubectl get svc -n monitoring prometheus-kube-prometheus-alertmanager >/dev/null 2>&1; then
    start_port_forward "prometheus-kube-prometheus-alertmanager" "monitoring" "30093" "9093" "Alertmanager"
fi

# Kubernetes Dashboard (если нужен дополнительный доступ)
if ! netstat -tlnp | grep -q ":8001 "; then
    echo "🔄 Запуск Kubernetes Dashboard proxy..."
    kubectl proxy --address=0.0.0.0 --port=8001 &
    sleep 2
    echo "✅ Kubernetes Dashboard proxy доступен на http://10.19.1.209:8001"
fi

echo ""
echo "🌐 Доступ к сервисам:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔧 Kubernetes Dashboard: https://10.19.1.209:30443"
echo "🚀 ArgoCD:               http://10.19.1.209:30444"
echo "📊 Grafana:              http://10.19.1.209:30300"
echo "📈 Prometheus:           http://10.19.1.209:30090"
echo "🚨 Alertmanager:         http://10.19.1.209:30093"
echo "🗄️  PostgreSQL:          10.19.1.209:30432"
echo "📋 Dashboard Proxy:      http://10.19.1.209:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📚 Логины и пароли:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ArgoCD:     admin / Q15LKJNm7K0WAFdw"
echo "Grafana:    admin / grafana123"
echo "PostgreSQL: admin / admin123 (DB: learningdb)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🎯 Для остановки всех port-forward:"
echo "   pkill -f 'kubectl port-forward'"
echo "   pkill -f 'kubectl proxy'"
echo ""
echo "✅ Все сервисы запущены и готовы к использованию!"
