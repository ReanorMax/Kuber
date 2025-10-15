# 📋 Полная инструкция: Создание kubeconfig для Lens

## 🎯 Цель
Быстро создать рабочий kubeconfig файл для подключения Lens к Kubernetes кластеру.

## 🔍 Шаг 1: Диагностика текущего состояния

### Проверить активный контекст:
```bash
kubectl config current-context
```

### Проверить текущий kubeconfig:
```bash
kubectl config view --minify --raw
```

### Проверить порты Kind кластера:
```bash
docker ps | grep kind
```

### Проверить слушающие порты:
```bash
netstat -tlnp | grep 6443
```

## 🔧 Шаг 2: Определить тип подключения

### Вариант A: Kind с пробросом портов на внешний IP
Если видите: `0.0.0.0:6443->6443/tcp` - можно подключаться напрямую

### Вариант B: Kind только с localhost портами  
Если видите: `127.0.0.1:XXXX->6443/tcp` - нужен SSH туннель

## 📝 Шаг 3: Создание kubeconfig файла

### Для прямого подключения (Вариант A):
```bash
# Получить рабочий kubeconfig
kubectl config view --minify --raw > /tmp/current-kubeconfig.yaml

# Создать файл для Lens
cat > /root/kubernetes-learning/lens-kubeconfig-direct.yaml << 'EOF'
apiVersion: v1
kind: Config
preferences: {}

clusters:
- cluster:
    insecure-skip-tls-verify: true
    server: https://10.19.1.209:6443  # Внешний IP сервера
  name: kind-learning-cluster

users:
- name: kind-learning-cluster-admin
  user:
    client-certificate-data: $(grep client-certificate-data /tmp/current-kubeconfig.yaml | cut -d' ' -f6)
    client-key-data: $(grep client-key-data /tmp/current-kubeconfig.yaml | cut -d' ' -f6)

contexts:
- context:
    cluster: kind-learning-cluster
    user: kind-learning-cluster-admin
    namespace: default
  name: kind-learning-cluster

current-context: kind-learning-cluster
EOF
```

### Для SSH туннеля (Вариант B):
```bash
# Получить рабочий kubeconfig
kubectl config view --minify --raw > /tmp/current-kubeconfig.yaml

# Извлечь сертификаты
CERT_DATA=$(grep client-certificate-data /tmp/current-kubeconfig.yaml | cut -d' ' -f6)
KEY_DATA=$(grep client-key-data /tmp/current-kubeconfig.yaml | cut -d' ' -f6)

# Создать файл для Lens
cat > /root/kubernetes-learning/lens-kubeconfig.yaml << EOF
apiVersion: v1
kind: Config
preferences: {}

clusters:
- cluster:
    insecure-skip-tls-verify: true
    server: https://127.0.0.1:6443  # Localhost для SSH туннеля
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
```

## 🚀 Шаг 4: Тестирование kubeconfig

```bash
# Тест прямого подключения
kubectl --kubeconfig=/root/kubernetes-learning/lens-kubeconfig-direct.yaml get nodes

# Тест SSH туннеля (сначала запустить туннель)
kubectl --kubeconfig=/root/kubernetes-learning/lens-kubeconfig.yaml get nodes
```

## 🔗 Шаг 5: Настройка SSH туннеля (если нужен)

### Определить правильный порт:
```bash
# Найти localhost порт Kind
docker ps | grep kind | grep 127.0.0.1
# Пример вывода: 127.0.0.1:33463->6443/tcp
```

### Запустить SSH туннель:
```bash
# Формат: ssh -L <внешний_порт>:127.0.0.1:<внутренний_порт> <пользователь>@<сервер> -N
ssh -L 6443:127.0.0.1:33463 root@10.19.1.209 -N
```

## 📤 Шаг 6: Передача файла пользователю

```bash
# Скачать файл на локальную машину
scp root@10.19.1.209:/root/kubernetes-learning/lens-kubeconfig.yaml ~/lens-kubeconfig.yaml
```

## 🎯 Шаг 7: Использование в Lens

1. **Открыть Lens**
2. **File → Add Cluster**
3. **Browse → выбрать скачанный файл**
4. **Add Cluster**
5. **Подключиться к кластеру**

## 🔧 Быстрые команды для диагностики

### Проверить все Kind кластеры:
```bash
kind get clusters
```

### Проверить статус конкретного кластера:
```bash
kubectl cluster-info
```

### Проверить доступность API:
```bash
curl -k https://10.19.1.209:6443/version
```

### Проверить SSH туннель:
```bash
# На клиентской машине
netstat -an | grep 6443
```

## 🚨 Частые проблемы и решения

### Проблема: "Invalid credentials"
**Решение**: Обновить сертификаты из текущего kubeconfig

### Проблема: "Connection refused"
**Решение**: 
- Проверить, что Kind кластер запущен
- Проверить SSH туннель (если используется)
- Проверить правильность портов

### Проблема: "Certificate verification failed"
**Решение**: Использовать `insecure-skip-tls-verify: true`

### Проблема: "Unable to connect to the server"
**Решение**: 
- Проверить сетевую доступность
- Проверить правильность IP адреса
- Проверить, что порт не заблокирован файрволом

## 📋 Чек-лист для быстрого создания

- [ ] Определить тип подключения (прямое/SSH туннель)
- [ ] Получить актуальные сертификаты из рабочего kubeconfig
- [ ] Создать файл с правильным server адресом
- [ ] Протестировать подключение
- [ ] Настроить SSH туннель (если нужен)
- [ ] Передать файл пользователю
- [ ] Дать инструкции по использованию в Lens

## 🎯 Автоматизированный скрипт

```bash
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
```

## 🎓 Заключение

Этот процесс позволяет быстро создавать рабочие kubeconfig файлы для Lens в любой ситуации. Главное - правильно определить тип подключения и использовать актуальные сертификаты из рабочего kubeconfig.
