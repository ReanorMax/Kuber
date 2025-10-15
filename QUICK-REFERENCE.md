# ⚡ Быстрая справка - Kubernetes Learning Environment

## 🚀 **Быстрый запуск**
```bash
cd /root/kubernetes-learning
./scripts/start-learning-environment.sh
```

## 🌐 **Доступ к сервисам**

| Сервис | URL | Логин | Пароль |
|--------|-----|-------|--------|
| **K8s Dashboard** | https://10.19.1.209:30443 | Токен | [длительный токен] |
| **Grafana** | http://10.19.1.209:30300 | admin | grafana123 |
| **ArgoCD** | http://10.19.1.209:30444 | admin | Q15LKJNm7K0WAFdw |
| **Prometheus** | http://10.19.1.209:30090 | - | - |
| **Alertmanager** | http://10.19.1.209:30093 | - | - |
| **PostgreSQL** | 10.19.1.209:30432 | admin | admin123 |

## 🔧 **Основные команды**

### **Проверка статуса:**
```bash
# Все Pod'ы
kubectl get pods --all-namespaces

# Port-forward процессы
ps aux | grep "kubectl port-forward"

# Открытые порты
netstat -tlnp | grep -E "(30443|30300|30444|30090|30093)"
```

### **Port-forward команды:**
```bash
# Kubernetes Dashboard
kubectl port-forward -n kubernetes-dashboard svc/kubernetes-dashboard 30443:443 --address=0.0.0.0 &

# Grafana
kubectl port-forward svc/grafana 30300:80 --address=0.0.0.0 &

# ArgoCD
kubectl port-forward -n argocd svc/argocd-server 30444:80 --address=0.0.0.0 &

# Prometheus
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 30090:9090 --address=0.0.0.0 &

# Alertmanager
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-alertmanager 30093:9093 --address=0.0.0.0 &
```

### **Остановка:**
```bash
# Все port-forward
pkill -f "kubectl port-forward"

# Конкретный сервис
pkill -f "kubectl port-forward.*grafana"
```

### **Создание kubeconfig для Lens:**
```bash
./scripts/create-lens-kubeconfig.sh
```

## 📚 **Документация**

### **Основные файлы:**
- `LEARNING-INDEX.md` - Главный индекс для изучения
- `WEB-SERVICES-STATUS.md` - Статус всех сервисов
- `PORT-FORWARDING-COMPLETE-GUIDE.md` - Полное руководство по пробросу портов
- `LENS-KUBECONFIG-GUIDE.md` - Подробная инструкция по настройке Lens
- `COMPLETE-LEARNING-ENVIRONMENT.md` - Общее руководство

### **Специализированные гайды:**
- `POSTGRESQL-LEARNING-GUIDE.md` - PostgreSQL
- `KAFKA-LEARNING-GUIDE.md` - Kafka
- `ARGOCD-GUIDE.md` - ArgoCD

## 🎯 **Порядок изучения**

1. **Начало**: `LEARNING-INDEX.md`
2. **Статус**: `WEB-SERVICES-STATUS.md`
3. **Проброс портов**: `PORT-FORWARDING-COMPLETE-GUIDE.md`
4. **Общее руководство**: `COMPLETE-LEARNING-ENVIRONMENT.md`
5. **Специализация**: Выберите нужный гайд

## 🚨 **Troubleshooting**

### **Сервис недоступен:**
1. Проверьте port-forward: `ps aux | grep "kubectl port-forward"`
2. Проверьте Pod'ы: `kubectl get pods --all-namespaces`
3. Перезапустите: `./scripts/start-learning-environment.sh`

### **Pod не запускается:**
1. Логи: `kubectl logs [POD_NAME]`
2. Описание: `kubectl describe pod [POD_NAME]`
3. События: `kubectl get events --sort-by=.metadata.creationTimestamp`

## 📞 **Поддержка**

Если что-то не работает:
1. Проверьте этот файл
2. Изучите `PORT-FORWARDING-COMPLETE-GUIDE.md`
3. Проверьте `WEB-SERVICES-STATUS.md`

---

**Создано**: $(date)
**Статус**: Готово к использованию! 🎉
