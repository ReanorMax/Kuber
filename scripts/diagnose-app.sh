#!/bin/bash
# Скрипт диагностики конкретного приложения в Kubernetes

set -e

APP_NAME=${1:-""}
NAMESPACE=${2:-"default"}

if [ -z "$APP_NAME" ]; then
    echo "🔧 Использование: $0 <app-name> [namespace]"
    echo ""
    echo "Примеры:"
    echo "  $0 grafana monitoring"
    echo "  $0 hello-world default"
    echo "  $0 nginx"
    exit 1
fi

echo "🔍 === Диагностика приложения: $APP_NAME ==="
echo "Namespace: $NAMESPACE"
echo "Время: $(date)"
echo "============================================="

# Проверяем существование namespace
if ! kubectl get namespace "$NAMESPACE" &>/dev/null; then
    echo "❌ Namespace '$NAMESPACE' не найден!"
    exit 1
fi

echo ""
echo "📊 1. Deployment Status:"
if kubectl get deployment $APP_NAME -n $NAMESPACE &>/dev/null; then
    kubectl get deployment $APP_NAME -n $NAMESPACE -o wide
    echo ""
    echo "Deployment подробности:"
    kubectl describe deployment $APP_NAME -n $NAMESPACE | grep -A 10 -E "(Replicas|Conditions|Events)"
else
    echo "⚠️  Deployment '$APP_NAME' не найден в namespace '$NAMESPACE'"
fi

echo ""
echo "🚀 2. Pod Status:"
PODS=$(kubectl get pods -l app=$APP_NAME -n $NAMESPACE --no-headers 2>/dev/null)
if [ -n "$PODS" ]; then
    kubectl get pods -l app=$APP_NAME -n $NAMESPACE -o wide
    echo ""
    echo "Pod подробности:"
    for pod in $(kubectl get pods -l app=$APP_NAME -n $NAMESPACE -o jsonpath='{.items[*].metadata.name}'); do
        echo "--- Pod: $pod ---"
        kubectl describe pod $pod -n $NAMESPACE | grep -A 5 -E "(Status|Conditions|Events)" | head -20
    done
else
    echo "❌ Pod'ы с label app=$APP_NAME не найдены в namespace '$NAMESPACE'"
    echo "Поиск по имени:"
    kubectl get pods -n $NAMESPACE | grep "$APP_NAME" || echo "Ничего не найдено"
fi

echo ""
echo "🌐 3. Service Status:"
SERVICES=$(kubectl get svc -l app=$APP_NAME -n $NAMESPACE --no-headers 2>/dev/null)
if [ -n "$SERVICES" ]; then
    kubectl get svc -l app=$APP_NAME -n $NAMESPACE -o wide
    echo ""
    echo "Endpoints:"
    for svc in $(kubectl get svc -l app=$APP_NAME -n $NAMESPACE -o jsonpath='{.items[*].metadata.name}'); do
        kubectl get endpoints $svc -n $NAMESPACE
    done
else
    echo "⚠️  Service с label app=$APP_NAME не найден"
    echo "Поиск по имени:"
    kubectl get svc -n $NAMESPACE | grep "$APP_NAME" || echo "Ничего не найдено"
fi

echo ""
echo "🔗 4. Ingress Status:"
INGRESS=$(kubectl get ingress -n $NAMESPACE --no-headers 2>/dev/null | grep "$APP_NAME" || true)
if [ -n "$INGRESS" ]; then
    kubectl get ingress -n $NAMESPACE | grep -E "(NAME|$APP_NAME)"
    echo ""
    echo "Ingress подробности:"
    kubectl describe ingress -n $NAMESPACE | grep -A 10 -B 5 "$APP_NAME"
else
    echo "⚠️  Ingress для '$APP_NAME' не найден"
fi

echo ""
echo "📝 5. Recent Events for $APP_NAME:"
EVENTS=$(kubectl get events --field-selector involvedObject.name~=$APP_NAME -n $NAMESPACE --no-headers 2>/dev/null | head -10)
if [ -n "$EVENTS" ]; then
    kubectl get events --field-selector involvedObject.name~=$APP_NAME -n $NAMESPACE | head -10
else
    echo "🔍 События не найдены, показываем последние события namespace:"
    kubectl get events -n $NAMESPACE --sort-by='.lastTimestamp' | tail -10
fi

echo ""
echo "📋 6. Pod Logs:"
POD_NAMES=$(kubectl get pods -l app=$APP_NAME -n $NAMESPACE -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)
if [ -n "$POD_NAMES" ]; then
    for pod in $POD_NAMES; do
        echo "--- Логи Pod: $pod (последние 20 строк) ---"
        kubectl logs $pod -n $NAMESPACE --tail=20 2>/dev/null || echo "Не удалось получить логи"
        
        # Если Pod перезапускался, показать логи предыдущего контейнера
        RESTART_COUNT=$(kubectl get pod $pod -n $NAMESPACE -o jsonpath='{.status.containerStatuses[0].restartCount}' 2>/dev/null || echo "0")
        if [ "$RESTART_COUNT" -gt 0 ]; then
            echo "--- Логи предыдущего контейнера (перезапусков: $RESTART_COUNT) ---"
            kubectl logs $pod -n $NAMESPACE --previous --tail=10 2>/dev/null || echo "Предыдущие логи недоступны"
        fi
    done
else
    echo "❌ Pod'ы не найдены для получения логов"
fi

echo ""
echo "📈 7. Resource Usage:"
if kubectl top pods -l app=$APP_NAME -n $NAMESPACE &>/dev/null; then
    kubectl top pods -l app=$APP_NAME -n $NAMESPACE
else
    echo "⚠️  Metrics недоступны (metrics-server не установлен или не работает)"
fi

echo ""
echo "🔧 8. Configuration Details:"
# ConfigMaps
CONFIGMAPS=$(kubectl get configmaps -n $NAMESPACE --no-headers 2>/dev/null | grep "$APP_NAME" || true)
if [ -n "$CONFIGMAPS" ]; then
    echo "ConfigMaps:"
    echo "$CONFIGMAPS"
else
    echo "ConfigMaps: не найдены"
fi

# Secrets
SECRETS=$(kubectl get secrets -n $NAMESPACE --no-headers 2>/dev/null | grep "$APP_NAME" || true)
if [ -n "$SECRETS" ]; then
    echo "Secrets:"
    echo "$SECRETS"
else
    echo "Secrets: не найдены"
fi

echo ""
echo "🛡️  9. Security Context:"
if [ -n "$POD_NAMES" ]; then
    for pod in $POD_NAMES; do
        echo "--- Security Context для Pod: $pod ---"
        kubectl get pod $pod -n $NAMESPACE -o jsonpath='{.spec.securityContext}' 2>/dev/null || echo "Security context не установлен"
        echo ""
        kubectl get pod $pod -n $NAMESPACE -o jsonpath='{.spec.containers[*].securityContext}' 2>/dev/null || echo "Container security context не установлен"
        echo ""
    done
fi

echo ""
echo "🎯 10. Troubleshooting Suggestions:"

# Проверяем типичные проблемы
if [ -z "$PODS" ]; then
    echo "❌ Проблема: Pod'ы не найдены"
    echo "💡 Проверьте:"
    echo "   - Правильность селекторов в Deployment"
    echo "   - Наличие ресурсов на узлах"
    echo "   - События кластера: kubectl get events -n $NAMESPACE"
fi

if [ -n "$PODS" ]; then
    # Проверяем статус подов
    NOT_RUNNING=$(echo "$PODS" | grep -v "Running" || true)
    if [ -n "$NOT_RUNNING" ]; then
        echo "⚠️  Обнаружены Pod'ы не в статусе Running"
        echo "💡 Проверьте логи и события для диагностики"
    fi
fi

if [ -z "$SERVICES" ] && [ -n "$PODS" ]; then
    echo "⚠️  Pod'ы есть, но Service не найден"
    echo "💡 Создайте Service для доступа к приложению"
fi

if [ -n "$SERVICES" ] && [ -z "$(kubectl get endpoints -l app=$APP_NAME -n $NAMESPACE -o jsonpath='{.items[*].subsets}' 2>/dev/null)" ]; then
    echo "❌ Service есть, но Endpoints пустые"
    echo "💡 Проверьте селекторы Service и labels Pod'ов"
fi

echo ""
echo "✅ Диагностика приложения '$APP_NAME' завершена!"
echo "Время завершения: $(date)"

# Опция для быстрого исправления (только для demo)
if [ "$3" = "--fix-common" ]; then
    echo ""
    echo "🔧 Попытка автоматического исправления типичных проблем..."
    
    # Перезапуск Deployment если Pod'ы не работают
    if [ -n "$NOT_RUNNING" ]; then
        echo "Перезапуск Deployment..."
        kubectl rollout restart deployment/$APP_NAME -n $NAMESPACE 2>/dev/null || echo "Не удалось перезапустить deployment"
    fi
fi
