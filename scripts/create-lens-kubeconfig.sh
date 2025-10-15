#!/bin/bash
# Скрипт для быстрого создания kubeconfig для Lens

echo "🔍 Диагностика кластера..."

# Проверка активного контекста
CONTEXT=$(kubectl config current-context)
echo "Активный контекст: $CONTEXT"

# Проверка портов Kind
echo "📊 Проверка портов Kind:"
docker ps | grep kind | grep 6443

# Получение сертификатов
echo "🔐 Получение сертификатов..."
kubectl config view --minify --raw > /tmp/current-kubeconfig.yaml
CERT_DATA=$(grep client-certificate-data /tmp/current-kubeconfig.yaml | cut -d' ' -f6)
KEY_DATA=$(grep client-key-data /tmp/current-kubeconfig.yaml | cut -d' ' -f6)

# Определение типа подключения
if docker ps | grep kind | grep -q "0.0.0.0:6443"; then
    echo "✅ Прямое подключение возможно"
    SERVER="https://10.19.1.209:6443"
    FILENAME="lens-kubeconfig-direct.yaml"
else
    echo "🔗 Требуется SSH туннель"
    SERVER="https://127.0.0.1:6443"
    FILENAME="lens-kubeconfig.yaml"
fi

# Создание файла
echo "📝 Создание файла: $FILENAME"
cat > /root/kubernetes-learning/$FILENAME << EOF
apiVersion: v1
kind: Config
preferences: {}

clusters:
- cluster:
    insecure-skip-tls-verify: true
    server: $SERVER
  name: kind-learning-cluster

users:
- name: kind-learning-cluster-admin
  user:
    client-certificate-data: $CERT_DATA
    client-key-data: $KEY_DATA

contexts:
- context:
    cluster: kind-learning-cluster
    user: kind-learning-cluster-admin
    namespace: default
  name: kind-learning-cluster

current-context: kind-learning-cluster
EOF

echo "✅ Файл создан: /root/kubernetes-learning/$FILENAME"

# Тестирование
echo "🧪 Тестирование подключения..."
if kubectl --kubeconfig=/root/kubernetes-learning/$FILENAME get nodes >/dev/null 2>&1; then
    echo "✅ Подключение работает!"
else
    echo "❌ Подключение не работает. Проверьте SSH туннель."
fi

echo "📤 Команда для скачивания:"
echo "scp root@10.19.1.209:/root/kubernetes-learning/$FILENAME ~/lens-kubeconfig.yaml"

echo ""
echo "🎯 Инструкция по использованию:"
echo "1. Скачайте файл на локальную машину"
echo "2. Откройте Lens"
echo "3. File → Add Cluster"
echo "4. Browse → выберите скачанный файл"
echo "5. Add Cluster"
echo ""
echo "📚 Подробная инструкция: LENS-KUBECONFIG-GUIDE.md"
