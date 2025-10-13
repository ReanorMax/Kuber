#!/bin/bash

# Скрипт для доступа к Kubernetes Dashboard

echo "🔐 Kubernetes Dashboard Access"
echo "================================"
echo ""

# Проверяем, что Dashboard развернут
if ! kubectl get deployment kubernetes-dashboard -n kubernetes-dashboard &> /dev/null; then
    echo "❌ Kubernetes Dashboard не установлен!"
    echo "Запустите: kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml"
    exit 1
fi

# Проверяем статус Dashboard
echo "📊 Статус Dashboard:"
kubectl get pods -n kubernetes-dashboard
echo ""

# Получаем токен для входа
echo "🔑 Токен для входа в Dashboard:"
TOKEN=$(kubectl -n kubernetes-dashboard create token admin-user 2>/dev/null)

if [ -z "$TOKEN" ]; then
    echo "❌ Не удалось получить токен. Возможно, сервисный аккаунт admin-user не создан."
    echo "Создайте его с помощью: kubectl apply -f manifests/dashboard-admin-user.yaml"
    exit 1
fi

echo "$TOKEN"
echo ""
echo "📋 Токен также сохранен в файл: dashboard-token.txt"
echo "$TOKEN" > /root/kubernetes-learning/dashboard-token.txt

echo ""
echo "🌐 Способы доступа к Dashboard:"
echo ""
echo "1. Через kubectl proxy (рекомендуется для локального доступа):"
echo "   kubectl proxy"
echo "   URL: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
echo ""
echo "2. Через port-forward (для доступа с других машин):"
echo "   kubectl port-forward -n kubernetes-dashboard svc/kubernetes-dashboard 8443:443 --address 0.0.0.0"
echo "   URL: https://<IP-сервера>:8443"
echo ""
echo "3. Через NodePort (если настроен в kind-config.yaml и кластер пересоздан):"
echo "   URL: https://<IP-сервера>:30443"
echo ""
echo "⚠️  При входе выберите 'Token' и вставьте токен, показанный выше"
echo ""

# Спрашиваем, запустить ли port-forward
read -p "Запустить port-forward для доступа к Dashboard? (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 Запускаем port-forward..."
    echo "Dashboard будет доступен по адресу: https://localhost:8443"
    echo "Для доступа с других машин используйте IP сервера вместо localhost"
    echo ""
    kubectl port-forward -n kubernetes-dashboard svc/kubernetes-dashboard 8443:443 --address 0.0.0.0
fi

