#!/bin/bash
# Скрипт для настройки /etc/hosts для доступа к сервисам

set -e

echo "🔧 Настройка DNS записей для локального доступа..."

# Получаем IP Minikube
MINIKUBE_IP=$(minikube ip)

if [ -z "$MINIKUBE_IP" ]; then
    echo "❌ Ошибка: Не удалось получить IP Minikube"
    echo "   Убедитесь что Minikube запущен: minikube status"
    exit 1
fi

echo "🌐 IP Minikube: $MINIKUBE_IP"

# Создаем резервную копию /etc/hosts
sudo cp /etc/hosts /etc/hosts.backup.$(date +%Y%m%d_%H%M%S)
echo "💾 Создана резервная копия /etc/hosts"

# Удаляем старые записи (если есть)
sudo sed -i '/# Kubernetes local services/,/# End Kubernetes local services/d' /etc/hosts

# Добавляем новые записи
echo "➕ Добавление DNS записей..."
cat << EOF | sudo tee -a /etc/hosts

# Kubernetes local services
$MINIKUBE_IP grafana.local
$MINIKUBE_IP prometheus.local  
$MINIKUBE_IP alertmanager.local
# End Kubernetes local services
EOF

echo "✅ DNS записи добавлены!"

# Проверяем доступность
echo "🧪 Проверка DNS резолвинга..."
for service in grafana.local prometheus.local alertmanager.local; do
    if ping -c 1 -W 1 $service &> /dev/null; then
        echo "  ✅ $service - OK"
    else
        echo "  ⚠️  $service - недоступен (возможно сервис еще не запущен)"
    fi
done

echo ""
echo "🎯 Теперь вы можете использовать:"
echo "  http://grafana.local"
echo "  http://prometheus.local"
echo "  http://alertmanager.local"
echo ""
echo "📝 Для отката изменений:"
echo "  sudo mv /etc/hosts.backup.* /etc/hosts"
