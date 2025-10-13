#!/bin/bash

# Скрипт для генерации kubeconfig для доступа с Windows через SSH туннель

set -e

echo "🔧 Генерация kubeconfig для Windows..."
echo "========================================"
echo ""

# Получаем IP сервера
SERVER_IP=$(hostname -I | awk '{print $1}')

# Получаем порт API сервера Kind
API_PORT=$(kubectl config view -o jsonpath='{.clusters[?(@.name=="kind-learning-cluster")].cluster.server}' | grep -oP ':\K[0-9]+$')

if [ -z "$API_PORT" ]; then
    echo "❌ Не удалось определить порт API сервера"
    exit 1
fi

echo "📍 IP сервера: $SERVER_IP"
echo "🔌 Порт API сервера: $API_PORT"
echo ""

# Создаем kubeconfig с localhost (для использования через SSH туннель)
cat > /root/kubernetes-learning/kubeconfig-for-windows.yaml <<EOF
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: $(kubectl config view --raw -o jsonpath='{.clusters[?(@.name=="kind-learning-cluster")].cluster.certificate-authority-data}')
    server: https://127.0.0.1:6443
  name: kind-learning-cluster
contexts:
- context:
    cluster: kind-learning-cluster
    user: kind-learning-cluster
  name: kind-learning-cluster
current-context: kind-learning-cluster
kind: Config
preferences: {}
users:
- name: kind-learning-cluster
  user:
    client-certificate-data: $(kubectl config view --raw -o jsonpath='{.users[?(@.name=="kind-learning-cluster")].user.client-certificate-data}')
    client-key-data: $(kubectl config view --raw -o jsonpath='{.users[?(@.name=="kind-learning-cluster")].user.client-key-data}')
EOF

echo "✅ Kubeconfig создан: kubeconfig-for-windows.yaml"
echo ""
echo "📋 Инструкции для Windows:"
echo ""
echo "1️⃣ Создайте SSH туннель (в PowerShell/CMD на Windows):"
echo "   ssh -L 6443:127.0.0.1:$API_PORT root@$SERVER_IP -N"
echo ""
echo "2️⃣ Скопируйте файл kubeconfig-for-windows.yaml на Windows"
echo ""
echo "3️⃣ Поместите в C:\\Users\\<Username>\\.kube\\config"
echo ""
echo "4️⃣ Откройте Lens - кластер появится автоматически!"
echo ""
echo "📖 Подробная инструкция: LENS-QUICKSTART.md"
echo ""

# Также выводим команду для копирования
echo "💡 Для просмотра содержимого kubeconfig:"
echo "   cat /root/kubernetes-learning/kubeconfig-for-windows.yaml"
echo ""
echo "💡 Для копирования на Windows через SCP:"
echo "   scp root@$SERVER_IP:/root/kubernetes-learning/kubeconfig-for-windows.yaml ."
echo ""

