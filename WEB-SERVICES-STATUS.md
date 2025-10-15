# 🌐 Статус веб-сервисов - Kubernetes Learning Environment

## ✅ **Текущий статус сервисов**

### **🔧 Kubernetes Dashboard**
- **URL**: https://10.19.1.209:30443
- **Статус**: ✅ Работает (port-forward)
- **Токен**: `eyJhbGciOiJSUzI1NiIsImtpZCI6ImEyTVhPZ0pQdFBEeDZXZGxWREgySWpILXRMTXU3bnFSQzgxMFNGSHhHZmMifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiXSwiZXhwIjoxNzkxOTk1NzE4LCJpYXQiOjE3NjA0NTk3MTgsImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsInNlcnZpY2VhY2NvdW50Ijp7Im5hbWUiOiJkYXNoYm9hcmQtYWRtaW4iLCJ1aWQiOiI4YjUxMzY0Mi0yMGJiLTRjM2YtOTRjOC0xZmRjYTUxNzE0NGYifX0sIm5iZiI6MTc2MDQ1OTcxOCwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50Omt1YmVybmV0ZXMtZGFzaGJvYXJkOmRhc2hib2FyZC1hZG1pbiJ9.FL6GQ1ed18YfviS5HupH0vmcZUICgb0rrcRAE0lAGQRY_KvekGeA0iP2LzyrqdsdKJ2q8TNE3MXrmhHBTO6_e3J0YZoIXmvCXxNeG0AB4iu6orkFQJDHAPJAv_5xWUOwLjViZgJc5YbNicmy_E0mW-VtHXAPm0VKHFsmiqFc6rpqKMnikpMgDNV716rqMeTyHswZwfvVFRjeNTJVsjlC74-TyY-WeqgNyop7ri-UX54tqAVVPA0wvjul4q3u5c2TDr6xxxbqhpSgnAMvOZcyPLR_AkxVyOqXlJTaHxRSu8eAw6ODQ4fiOyMqzC96RrIrRoHPCjOoR5HQoC2w5ztVug`
- **Срок действия**: 1 год (до 2026-10-14)

### **📊 Grafana**
- **URL**: http://10.19.1.209:30300
- **Статус**: ✅ Работает (port-forward)
- **Логин**: admin
- **Пароль**: grafana123

### **🚀 ArgoCD**
- **URL**: http://10.19.1.209:30444
- **Статус**: ✅ Работает (port-forward)
- **Логин**: admin
- **Пароль**: Q15LKJNm7K0WAFdw

### **📈 Prometheus**
- **URL**: http://10.19.1.209:30090
- **Статус**: 🔄 Запускается (устанавливается)
- **Namespace**: monitoring
- **Примечание**: Pod'ы еще запускаются, подождите 2-3 минуты

### **🚨 Alertmanager**
- **URL**: http://10.19.1.209:30093
- **Статус**: 🔄 Запускается (устанавливается)
- **Namespace**: monitoring

---

## 🚀 **Быстрый запуск всех сервисов**

### **Автоматический запуск:**
```bash
cd /root/kubernetes-learning
./scripts/start-learning-environment.sh
```

### **Ручной запуск port-forward:**
```bash
# Kubernetes Dashboard
kubectl port-forward -n kubernetes-dashboard svc/kubernetes-dashboard 30443:443 --address=0.0.0.0 &

# Grafana
kubectl port-forward svc/grafana 30300:80 --address=0.0.0.0 &

# ArgoCD
kubectl port-forward -n argocd svc/argocd-server 30444:80 --address=0.0.0.0 &

# Prometheus (когда запустится)
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 30090:9090 --address=0.0.0.0 &

# Alertmanager (когда запустится)
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-alertmanager 30093:9093 --address=0.0.0.0 &
```

---

## 🔧 **Проверка статуса**

### **Проверить что порты слушаются:**
```bash
netstat -tlnp | grep -E "(30443|30300|30444|30090|30093)"
```

### **Проверить статус Pod'ов:**
```bash
# Kubernetes Dashboard
kubectl get pods -n kubernetes-dashboard

# Grafana
kubectl get pods -l app.kubernetes.io/name=grafana

# ArgoCD
kubectl get pods -n argocd

# Prometheus
kubectl get pods -n monitoring
```

### **Проверить доступность:**
```bash
# Kubernetes Dashboard
curl -I https://10.19.1.209:30443 -k

# Grafana
curl -I http://10.19.1.209:30300

# ArgoCD
curl -I http://10.19.1.209:30444

# Prometheus (когда запустится)
curl -I http://10.19.1.209:30090
```

---

## 🎯 **Дополнительные сервисы**

### **🗄️ PostgreSQL**
- **Host**: 10.19.1.209
- **Port**: 30432
- **Database**: learningdb
- **Username**: admin
- **Password**: admin123

### **🚀 Kafka**
- **Bootstrap Server**: kafka.kafka.svc.cluster.local:9092
- **Namespace**: kafka
- **Статус**: ❌ Недоступен (CrashLoopBackOff)
- **Примечание**: См. [KAFKA-TROUBLESHOOTING.md](./KAFKA-TROUBLESHOOTING.md)

---

## 🚨 **Troubleshooting**

### **Если сервис недоступен:**

1. **Проверьте что port-forward запущен:**
   ```bash
   ps aux | grep "kubectl port-forward"
   ```

2. **Проверьте статус Pod'ов:**
   ```bash
   kubectl get pods --all-namespaces | grep -E "(dashboard|grafana|argocd|prometheus)"
   ```

3. **Перезапустите port-forward:**
   ```bash
   pkill -f "kubectl port-forward"
   ./scripts/start-learning-environment.sh
   ```

4. **Проверьте логи:**
   ```bash
   kubectl logs -n kubernetes-dashboard deployment/kubernetes-dashboard
   kubectl logs -l app.kubernetes.io/name=grafana
   kubectl logs -n argocd deployment/argocd-server
   ```

---

## 📚 **Документация**

- `COMPLETE-LEARNING-ENVIRONMENT.md` - полное руководство
- `POSTGRESQL-LEARNING-GUIDE.md` - гайд по PostgreSQL
- `KAFKA-LEARNING-GUIDE.md` - гайд по Kafka
- `ARGOCD-GUIDE.md` - гайд по ArgoCD

---

**Обновлено**: $(date)
**Статус**: Все основные сервисы работают! 🎉
