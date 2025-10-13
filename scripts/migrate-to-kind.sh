#!/bin/bash
# Скрипт миграции с Minikube на Kind для лучшего внешнего доступа

set -e

echo "🚀 === Миграция с Minikube на Kind ==="
echo "===================================="

# Проверяем что Kind установлен
if ! command -v kind &> /dev/null; then
    echo "📦 Устанавливаю Kind..."
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
    echo "✅ Kind установлен!"
fi

echo ""
echo "💾 1. Сохраняем текущую конфигурацию Minikube..."

# Создаем backup папку
mkdir -p backup/minikube-config

# Сохраняем Helm values
if helm list -n monitoring | grep -q prometheus; then
    echo "📋 Сохраняю Helm values..."
    helm get values prometheus -n monitoring > backup/minikube-config/prometheus-values.yaml
    echo "✅ Helm values сохранены в backup/minikube-config/"
fi

# Сохраняем важные манифесты
echo "📋 Сохраняю кастомные манифесты..."
cp -r manifests/ backup/minikube-config/
echo "✅ Манифесты сохранены"

echo ""
echo "🛑 2. Останавливаем Minikube (не удаляем - можно вернуться)..."
minikube stop || echo "Minikube уже остановлен"

echo ""
echo "🐳 3. Проверяю Docker..."
if ! docker ps &>/dev/null; then
    echo "❌ Docker не запущен! Запустите Docker и попробуйте снова."
    exit 1
fi
echo "✅ Docker работает"

echo ""
echo "⚙️  4. Создаю Kind кластер с внешним доступом..."
cat << EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: learning-cluster
networking:
  podSubnet: "10.244.0.0/16"
  serviceSubnet: "10.96.0.0/12"
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30080
    hostPort: 3000
    protocol: TCP
  - containerPort: 30090  
    hostPort: 9090
    protocol: TCP
  - containerPort: 30093
    hostPort: 9093
    protocol: TCP
  - containerPort: 80
    hostPort: 8080
    protocol: TCP
  - containerPort: 443
    hostPort: 8443
    protocol: TCP
EOF

echo "✅ Kind кластер создан!"

echo ""
echo "🔧 5. Настраиваю kubectl context..."
kubectl config use-context kind-learning-cluster
echo "✅ Переключен на Kind кластер"

echo ""
echo "📋 6. Проверяю статус кластера..."
kubectl get nodes
kubectl cluster-info

echo ""
echo "📦 7. Устанавливаю Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo "⏱️  Ожидаю готовности Ingress Controller..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

echo "✅ Ingress Controller готов!"

echo ""
echo "📊 8. Добавляю Helm репозиторий..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

echo ""
echo "🎯 9. Устанавливаю мониторинг с правильными портами..."
helm install prometheus prometheus-community/kube-prometheus-stack \
    --namespace monitoring \
    --create-namespace \
    --set grafana.adminPassword=admin123 \
    --set grafana.service.type=NodePort \
    --set grafana.service.nodePort=30080 \
    --set prometheus.service.type=NodePort \
    --set prometheus.service.nodePort=30090 \
    --set alertmanager.service.type=NodePort \
    --set alertmanager.service.nodePort=30093 \
    --wait --timeout=10m

echo ""
echo "🎉 === Миграция завершена! ==="

# Получаем внешний IP
EXTERNAL_IP=$(hostname -I | awk '{print $1}')
echo ""
echo "🌟 Теперь сервисы доступны БЕЗ port-forward:"
echo "  📊 Grafana:      http://$EXTERNAL_IP:3000 (admin/admin123)"
echo "  📈 Prometheus:   http://$EXTERNAL_IP:9090"
echo "  🚨 Alertmanager: http://$EXTERNAL_IP:9093"
echo ""
echo "📋 Также доступны через localhost на сервере:"
echo "  📊 Grafana:      http://localhost:3000"
echo "  📈 Prometheus:   http://localhost:9090"
echo "  🚨 Alertmanager: http://localhost:9093"

echo ""
echo "⚡ Преимущества Kind vs Minikube:"
echo "  ✅ Быстрее запуск (30сек vs 3мин)"
echo "  ✅ Меньше ресурсов (Docker vs VM)"
echo "  ✅ Простой внешний доступ"
echo "  ✅ Нет проблем с port-forward"
echo "  ✅ Стабильная сеть"

echo ""
echo "🔄 Управление Kind кластером:"
echo "  kind get clusters                    # Список кластеров"
echo "  kind delete cluster --name=learning-cluster  # Удалить"
echo "  kubectl config get-contexts         # Доступные контексты"
echo "  kubectl config use-context minikube # Вернуться к Minikube"

echo ""
echo "💡 Если хотите вернуться к Minikube:"
echo "  minikube start"
echo "  kubectl config use-context minikube"

echo ""
echo "🎯 Попробуйте открыть Grafana: http://$EXTERNAL_IP:3000"
