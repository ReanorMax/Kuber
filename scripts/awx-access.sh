#!/bin/bash

# AWX Quick Access Script
# Предоставляет быстрый доступ к AWX и информацию о статусе

echo "=== AWX Quick Access ==="
echo

# Проверяем статус AWX
echo "📊 AWX Status:"
kubectl get awx -n awx 2>/dev/null || echo "AWX resource not found"
echo

# Проверяем Pod'ы
echo "🔍 AWX Pods Status:"
kubectl get pods -n awx
echo

# Проверяем сервисы
echo "🌐 AWX Services:"
kubectl get svc -n awx
echo

# Получаем IP сервера
SERVER_IP=$(hostname -I | awk '{print $1}')

echo "🚀 AWX Access Information:"
echo "   URL: http://${SERVER_IP}:30800"
echo "   Login: admin"
echo "   Password: AWXadmin123!"
echo

# Проверяем доступность
echo "🔗 Testing AWX connectivity..."
if curl -s --connect-timeout 5 http://${SERVER_IP}:30800 > /dev/null; then
    echo "   ✅ AWX is accessible!"
else
    echo "   ⏳ AWX is still starting up..."
fi
echo

# Показываем логи если есть проблемы
TASK_POD=$(kubectl get pods -n awx -l app.kubernetes.io/name=awx-task --no-headers 2>/dev/null | awk '{print $1}')
if [ ! -z "$TASK_POD" ]; then
    TASK_STATUS=$(kubectl get pod -n awx $TASK_POD --no-headers | awk '{print $3}')
    if [ "$TASK_STATUS" = "Init:0/2" ] || [ "$TASK_STATUS" = "Init:1/2" ]; then
        echo "📋 Task Pod is initializing. Last init logs:"
        kubectl logs -n awx $TASK_POD -c init-database --tail=5 2>/dev/null || echo "   No logs available yet"
        echo
    fi
fi

echo "💡 Tips:"
echo "   - AWX Web UI provides Ansible automation platform"
echo "   - Use it to manage playbooks, inventories, and credentials"
echo "   - Deploy applications to external servers via SSH"
echo "   - Monitor job execution in real-time"
echo

echo "📚 Documentation:"
echo "   - AWX Guide: docs/awx-deployment-guide.md"
echo "   - Kubernetes Concepts: docs/INDEX.md"
echo "   - Quick Links: QUICK-LINKS.md"
echo
