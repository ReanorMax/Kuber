#!/bin/bash

# Оптимизированный скрипт для быстрого доступа к Kubernetes Dashboard

echo "🚀 Быстрый доступ к Kubernetes Dashboard"
echo "========================================"
echo ""

# Останавливаем старые процессы
echo "🔄 Останавливаем старые соединения..."
pkill -f "port-forward.*kubernetes-dashboard" 2>/dev/null
sleep 2

# Проверяем статус Dashboard
echo "📊 Проверяем статус Dashboard..."
if ! kubectl get deployment kubernetes-dashboard -n kubernetes-dashboard &> /dev/null; then
    echo "❌ Kubernetes Dashboard не установлен!"
    exit 1
fi

# Масштабируем ресурсы для лучшей производительности
echo "⚡ Оптимизируем ресурсы кластера..."
kubectl scale deployment nginx-demo --replicas=1 2>/dev/null
kubectl scale deployment redis-demo --replicas=1 -n demo-apps 2>/dev/null
kubectl scale deployment example-metrics-app --replicas=1 2>/dev/null

# Запускаем port-forward
echo "🌐 Запускаем оптимизированный доступ..."
kubectl port-forward -n kubernetes-dashboard svc/kubernetes-dashboard 9443:443 --address 0.0.0.0 &
PORT_FORWARD_PID=$!

# Ждем запуска
sleep 3

# Проверяем доступность
if curl -k -s https://localhost:9443 > /dev/null; then
    echo "✅ Dashboard готов!"
else
    echo "❌ Ошибка запуска Dashboard"
    kill $PORT_FORWARD_PID 2>/dev/null
    exit 1
fi

# Получаем токен
echo "🔑 Генерируем токен для входа..."
TOKEN=$(kubectl -n kubernetes-dashboard create token admin-user 2>/dev/null)

if [ -z "$TOKEN" ]; then
    echo "❌ Не удалось получить токен"
    kill $PORT_FORWARD_PID 2>/dev/null
    exit 1
fi

echo ""
echo "🎉 Dashboard готов к использованию!"
echo ""
echo "🔗 URL: https://10.19.1.209:9443"
echo ""
echo "🔑 Токен для входа:"
echo "$TOKEN"
echo ""
echo "💡 Советы для быстрой работы:"
echo "  • Используйте фильтры по namespace"
echo "  • Переключайтесь между разделами постепенно"
echo "  • Избегайте одновременного открытия всех вкладок"
echo ""
echo "⚠️  При первом заходе браузер покажет предупреждение о сертификате"
echo "   Нажмите 'Продолжить' или 'Advanced' → 'Proceed to site'"
echo ""
echo "🛑 Для остановки: Ctrl+C"

# Сохраняем PID для возможности остановки
echo $PORT_FORWARD_PID > /tmp/dashboard-pid

# Ждем завершения
wait $PORT_FORWARD_PID
