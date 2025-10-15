# 🚀 Kafka Learning Guide - Kubernetes

## 📋 Обзор

Apache Kafka установлен в Kubernetes как потоковая платформа для обработки данных в реальном времени.

### **Архитектура:**
- **Namespace**: `kafka`
- **Zookeeper**: 1 реплика (координация)
- **Kafka Broker**: 1 реплика (обработка сообщений)
- **Services**: ClusterIP для внутреннего доступа

---

## 🌐 Доступ к Kafka

### **Внутри кластера:**
```
Bootstrap Server: kafka.kafka.svc.cluster.local:9092
Zookeeper: zookeeper.kafka.svc.cluster.local:2181
```

### **Внешний доступ:**
```
Bootstrap Server: 10.19.1.209:9092 (если настроен NodePort)
```

---

## 🚀 Задачи для обучения

### **Уровень 1: Основы Kafka**

#### **Задача 1.1: Создание первого топика**
```bash
# Подключение к Kafka контейнеру
kubectl exec -it -n kafka deployment/kafka -- /bin/bash

# Создание топика
kafka-topics --create \
  --topic learning-topic \
  --bootstrap-server localhost:9092 \
  --partitions 3 \
  --replication-factor 1

# Просмотр топиков
kafka-topics --list --bootstrap-server localhost:9092

# Описание топика
kafka-topics --describe \
  --topic learning-topic \
  --bootstrap-server localhost:9092
```

#### **Задача 1.2: Отправка и получение сообщений**
```bash
# В одном терминале - Producer (отправитель)
kafka-console-producer \
  --topic learning-topic \
  --bootstrap-server localhost:9092

# В другом терминале - Consumer (получатель)
kafka-console-consumer \
  --topic learning-topic \
  --bootstrap-server localhost:9092 \
  --from-beginning
```

#### **Задача 1.3: Работа с группами потребителей**
```bash
# Consumer с группой
kafka-console-consumer \
  --topic learning-topic \
  --bootstrap-server localhost:9092 \
  --group learning-group \
  --from-beginning

# Просмотр групп
kafka-consumer-groups \
  --bootstrap-server localhost:9092 \
  --list

# Описание группы
kafka-consumer-groups \
  --bootstrap-server localhost:9092 \
  --group learning-group \
  --describe
```

### **Уровень 2: Продвинутые операции**

#### **Задача 2.1: Управление партициями**
```bash
# Создание топика с несколькими партициями
kafka-topics --create \
  --topic multi-partition-topic \
  --bootstrap-server localhost:9092 \
  --partitions 5 \
  --replication-factor 1

# Увеличение количества партиций
kafka-topics --alter \
  --topic multi-partition-topic \
  --partitions 10 \
  --bootstrap-server localhost:9092

# Просмотр информации о партициях
kafka-topics --describe \
  --topic multi-partition-topic \
  --bootstrap-server localhost:9092
```

#### **Задача 2.2: Настройка retention (хранения)**
```bash
# Создание топика с настройками retention
kafka-topics --create \
  --topic retention-topic \
  --bootstrap-server localhost:9092 \
  --partitions 3 \
  --replication-factor 1 \
  --config retention.ms=3600000 \
  --config retention.bytes=10485760

# Изменение retention для существующего топика
kafka-configs --alter \
  --entity-type topics \
  --entity-name retention-topic \
  --add-config retention.ms=7200000 \
  --bootstrap-server localhost:9092
```

#### **Задача 2.3: Мониторинг топиков**
```bash
# Просмотр логов топика
kafka-dump-log \
  --files /var/lib/kafka/data/learning-topic-0/00000000000000000000.log \
  --print-data-log

# Просмотр смещений (offsets)
kafka-consumer-groups \
  --bootstrap-server localhost:9092 \
  --group learning-group \
  --describe \
  --verbose
```

### **Уровень 3: Практические проекты**

#### **Проект 1: Система логирования**
```bash
# Создание топика для логов
kafka-topics --create \
  --topic application-logs \
  --bootstrap-server localhost:9092 \
  --partitions 5 \
  --replication-factor 1

# Producer для логов (симуляция)
kafka-console-producer \
  --topic application-logs \
  --bootstrap-server localhost:9092

# Отправка тестовых логов
# {"level":"INFO","message":"User login","timestamp":"2025-10-15T10:00:00Z","user_id":123}
# {"level":"ERROR","message":"Database connection failed","timestamp":"2025-10-15T10:01:00Z","error":"Connection timeout"}
# {"level":"WARN","message":"High memory usage","timestamp":"2025-10-15T10:02:00Z","memory_usage":"85%"}

# Consumer для обработки логов
kafka-console-consumer \
  --topic application-logs \
  --bootstrap-server localhost:9092 \
  --group log-processor \
  --from-beginning
```

#### **Проект 2: Система событий пользователей**
```bash
# Создание топиков для событий
kafka-topics --create \
  --topic user-events \
  --bootstrap-server localhost:9092 \
  --partitions 3 \
  --replication-factor 1

kafka-topics --create \
  --topic order-events \
  --bootstrap-server localhost:9092 \
  --partitions 3 \
  --replication-factor 1

# Отправка событий пользователей
kafka-console-producer \
  --topic user-events \
  --bootstrap-server localhost:9092

# Примеры событий:
# {"event_type":"user_registered","user_id":456,"email":"user@example.com","timestamp":"2025-10-15T10:00:00Z"}
# {"event_type":"user_login","user_id":456,"ip_address":"192.168.1.100","timestamp":"2025-10-15T10:05:00Z"}
# {"event_type":"user_logout","user_id":456,"session_duration":1800,"timestamp":"2025-10-15T10:35:00Z"}
```

#### **Проект 3: Потоковая обработка данных**
```bash
# Создание топика для метрик
kafka-topics --create \
  --topic system-metrics \
  --bootstrap-server localhost:9092 \
  --partitions 5 \
  --replication-factor 1

# Producer для метрик
kafka-console-producer \
  --topic system-metrics \
  --bootstrap-server localhost:9092

# Примеры метрик:
# {"metric":"cpu_usage","value":45.2,"timestamp":"2025-10-15T10:00:00Z","host":"server1"}
# {"metric":"memory_usage","value":78.5,"timestamp":"2025-10-15T10:00:00Z","host":"server1"}
# {"metric":"disk_usage","value":23.1,"timestamp":"2025-10-15T10:00:00Z","host":"server1"}

# Consumer для обработки метрик
kafka-console-consumer \
  --topic system-metrics \
  --bootstrap-server localhost:9092 \
  --group metrics-processor \
  --from-beginning
```

---

## 🔧 Полезные команды kubectl

### **Управление Kafka:**
```bash
# Просмотр Pod'ов
kubectl get pods -n kafka

# Логи Kafka
kubectl logs -n kafka deployment/kafka -f

# Логи Zookeeper
kubectl logs -n kafka deployment/zookeeper -f

# Подключение к контейнеру
kubectl exec -it -n kafka deployment/kafka -- /bin/bash

# Просмотр сервисов
kubectl get svc -n kafka
```

### **Отладка:**
```bash
# Проверка статуса Pod'ов
kubectl describe pod -n kafka -l app=kafka
kubectl describe pod -n kafka -l app=zookeeper

# Просмотр событий
kubectl get events -n kafka --sort-by=.metadata.creationTimestamp

# Проверка ресурсов
kubectl top pod -n kafka
```

---

## 📊 Мониторинг Kafka

### **Встроенные инструменты:**
```bash
# Просмотр метрик топиков
kafka-log-dirs \
  --bootstrap-server localhost:9092 \
  --describe \
  --json

# Просмотр смещений всех групп
kafka-consumer-groups \
  --bootstrap-server localhost:9092 \
  --all-groups \
  --describe

# Просмотр информации о брокере
kafka-broker-api-versions \
  --bootstrap-server localhost:9092
```

### **Интеграция с Grafana:**
1. Установите Kafka Exporter для Prometheus
2. Настройте Prometheus для сбора метрик Kafka
3. Создайте дашборды в Grafana для:
   - Throughput (пропускная способность)
   - Lag (задержка потребителей)
   - Partition distribution
   - Broker health

---

## 🎯 Практические сценарии

### **Сценарий 1: Event Sourcing**
```bash
# Создание топика для событий домена
kafka-topics --create \
  --topic domain-events \
  --bootstrap-server localhost:9092 \
  --partitions 10 \
  --replication-factor 1 \
  --config cleanup.policy=compact

# Отправка событий с ключами
kafka-console-producer \
  --topic domain-events \
  --bootstrap-server localhost:9092 \
  --property "parse.key=true" \
  --property "key.separator=:"

# Примеры событий с ключами:
# user:123:{"event_type":"user_created","user_id":123,"name":"John Doe"}
# user:123:{"event_type":"user_updated","user_id":123,"name":"John Smith"}
# order:456:{"event_type":"order_created","order_id":456,"user_id":123,"amount":99.99}
```

### **Сценарий 2: Data Pipeline**
```bash
# Создание топиков для пайплайна
kafka-topics --create \
  --topic raw-data \
  --bootstrap-server localhost:9092 \
  --partitions 5 \
  --replication-factor 1

kafka-topics --create \
  --topic processed-data \
  --bootstrap-server localhost:9092 \
  --partitions 5 \
  --replication-factor 1

# Producer для сырых данных
kafka-console-producer \
  --topic raw-data \
  --bootstrap-server localhost:9092

# Consumer для обработки
kafka-console-consumer \
  --topic raw-data \
  --bootstrap-server localhost:9092 \
  --group data-processor \
  --from-beginning

# Producer для обработанных данных
kafka-console-producer \
  --topic processed-data \
  --bootstrap-server localhost:9092
```

---

## 🚨 Troubleshooting

### **Частые проблемы:**

1. **Kafka не запускается**
   ```bash
   kubectl logs -n kafka deployment/kafka
   kubectl describe pod -n kafka -l app=kafka
   ```

2. **Zookeeper недоступен**
   ```bash
   kubectl logs -n kafka deployment/zookeeper
   kubectl get svc -n kafka
   ```

3. **Не удается создать топик**
   - Проверьте что Kafka запущен
   - Проверьте подключение к Zookeeper
   - Проверьте права доступа

4. **Consumer не получает сообщения**
   - Проверьте группу потребителей
   - Проверьте смещения (offsets)
   - Используйте `--from-beginning` для чтения с начала

---

## 📚 Дополнительные ресурсы

### **Kafka документация:**
- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)
- [Kafka Streams](https://kafka.apache.org/documentation/streams/)
- [Kafka Connect](https://kafka.apache.org/documentation/#connect)

### **Kubernetes + Kafka:**
- [Kafka on Kubernetes](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/)
- [Confluent for Kubernetes](https://docs.confluent.io/operator/current/overview.html)

---

**Создано**: $(date)
**Kafka Version**: 7.4.0
**Namespace**: kafka
**Статус**: Готово к обучению! 🎉
