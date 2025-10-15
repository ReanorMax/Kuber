# 🗄️ PostgreSQL Learning Guide - Kubernetes

## 📋 Обзор

PostgreSQL установлен в Kubernetes как StatefulSet с PersistentVolume для хранения данных.

### **Архитектура:**
- **Namespace**: `postgresql`
- **Deployment**: `postgres` (1 реплика)
- **Service**: `postgres` (ClusterIP) + `postgres-nodeport` (NodePort)
- **Storage**: PersistentVolumeClaim (2GB)
- **ConfigMap**: `postgres-config` (переменные окружения)

---

## 🌐 Доступ к PostgreSQL

### **Внутри кластера:**
```
Host: postgres.postgresql.svc.cluster.local
Port: 5432
Database: learningdb
Username: admin
Password: admin123
```

### **Внешний доступ:**
```
Host: 10.19.1.209
Port: 30432
Database: learningdb
Username: admin
Password: admin123
```

---

## 🚀 Задачи для обучения

### **Уровень 1: Подключение и базовые операции**

#### **Задача 1.1: Подключение к PostgreSQL**
```bash
# Подключение через kubectl exec
kubectl exec -it -n postgresql deployment/postgres -- psql -U admin -d learningdb

# Подключение с внешнего хоста (если установлен psql)
psql -h 10.19.1.209 -p 30432 -U admin -d learningdb
```

#### **Задача 1.2: Создание первой таблицы**
```sql
-- В psql консоли:
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Проверка таблицы
\dt

-- Описание таблицы
\d users
```

#### **Задача 1.3: Вставка и выборка данных**
```sql
-- Вставка данных
INSERT INTO users (name, email) VALUES 
    ('John Doe', 'john@example.com'),
    ('Jane Smith', 'jane@example.com'),
    ('Bob Johnson', 'bob@example.com');

-- Выборка всех данных
SELECT * FROM users;

-- Выборка с условием
SELECT * FROM users WHERE name LIKE 'J%';

-- Подсчет записей
SELECT COUNT(*) FROM users;
```

### **Уровень 2: Продвинутые операции**

#### **Задача 2.1: Создание индексов**
```sql
-- Создание индекса по email
CREATE INDEX idx_users_email ON users(email);

-- Создание составного индекса
CREATE INDEX idx_users_name_email ON users(name, email);

-- Просмотр индексов
\di
```

#### **Задача 2.2: Работа с транзакциями**
```sql
-- Начало транзакции
BEGIN;

-- Вставка данных
INSERT INTO users (name, email) VALUES ('Test User', 'test@example.com');

-- Проверка данных (в той же транзакции)
SELECT * FROM users WHERE email = 'test@example.com';

-- Откат транзакции
ROLLBACK;

-- Проверка что данные не сохранились
SELECT * FROM users WHERE email = 'test@example.com';
```

#### **Задача 2.3: Создание представлений (Views)**
```sql
-- Создание представления
CREATE VIEW active_users AS
SELECT id, name, email, created_at
FROM users
WHERE created_at > CURRENT_DATE - INTERVAL '30 days';

-- Использование представления
SELECT * FROM active_users;
```

### **Уровень 3: Администрирование**

#### **Задача 3.1: Управление пользователями и правами**
```sql
-- Создание нового пользователя
CREATE USER app_user WITH PASSWORD 'app_password';

-- Предоставление прав на базу данных
GRANT CONNECT ON DATABASE learningdb TO app_user;
GRANT USAGE ON SCHEMA public TO app_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON users TO app_user;

-- Проверка прав
\du
```

#### **Задача 3.2: Бэкап и восстановление**
```bash
# Создание бэкапа
kubectl exec -n postgresql deployment/postgres -- pg_dump -U admin learningdb > backup.sql

# Восстановление из бэкапа
kubectl exec -i -n postgresql deployment/postgres -- psql -U admin learningdb < backup.sql
```

#### **Задача 3.3: Мониторинг производительности**
```sql
-- Просмотр активных соединений
SELECT * FROM pg_stat_activity;

-- Размер базы данных
SELECT pg_size_pretty(pg_database_size('learningdb'));

-- Размер таблиц
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

---

## 🔧 Полезные команды kubectl

### **Управление PostgreSQL:**
```bash
# Просмотр Pod'ов
kubectl get pods -n postgresql

# Логи PostgreSQL
kubectl logs -n postgresql deployment/postgres -f

# Подключение к контейнеру
kubectl exec -it -n postgresql deployment/postgres -- /bin/bash

# Масштабирование (если нужно)
kubectl scale deployment postgres -n postgresql --replicas=2

# Просмотр PersistentVolume
kubectl get pvc -n postgresql
kubectl describe pvc postgres-pvc -n postgresql
```

### **Отладка:**
```bash
# Проверка статуса Pod'а
kubectl describe pod -n postgresql -l app=postgres

# Просмотр событий
kubectl get events -n postgresql --sort-by=.metadata.creationTimestamp

# Проверка ресурсов
kubectl top pod -n postgresql
```

---

## 📊 Мониторинг в Grafana

### **Подключение PostgreSQL к Grafana:**
1. Откройте Grafana: http://10.19.1.209:30300
2. Перейдите в Configuration → Data Sources
3. Добавьте PostgreSQL источник:
   - **Name**: PostgreSQL
   - **Type**: PostgreSQL
   - **Host**: postgres.postgresql.svc.cluster.local:5432
   - **Database**: learningdb
   - **User**: admin
   - **Password**: admin123

### **Полезные дашборды:**
- **Database Overview** - общий обзор БД
- **Query Performance** - производительность запросов
- **Connection Stats** - статистика соединений
- **Table Sizes** - размеры таблиц

---

## 🎯 Практические проекты

### **Проект 1: Система блога**
```sql
-- Создание таблиц для блога
CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    author_id INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE comments (
    id SERIAL PRIMARY KEY,
    post_id INTEGER REFERENCES posts(id),
    author_id INTEGER REFERENCES users(id),
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Создание индексов для производительности
CREATE INDEX idx_posts_author ON posts(author_id);
CREATE INDEX idx_posts_created ON posts(created_at);
CREATE INDEX idx_comments_post ON comments(post_id);
```

### **Проект 2: Система заказов**
```sql
-- Создание таблиц для e-commerce
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    description TEXT,
    stock_quantity INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id),
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER NOT NULL,
    price DECIMAL(10,2) NOT NULL
);
```

---

## 🚨 Troubleshooting

### **Частые проблемы:**

1. **Pod не запускается**
   ```bash
   kubectl describe pod -n postgresql -l app=postgres
   kubectl logs -n postgresql deployment/postgres
   ```

2. **Не удается подключиться**
   - Проверьте что Pod запущен: `kubectl get pods -n postgresql`
   - Проверьте Service: `kubectl get svc -n postgresql`
   - Проверьте логи: `kubectl logs -n postgresql deployment/postgres`

3. **Проблемы с хранилищем**
   ```bash
   # Проверка PVC
   kubectl get pvc -n postgresql
   kubectl describe pvc postgres-pvc -n postgresql
   
   # Проверка PV
   kubectl get pv
   ```

4. **Нехватка ресурсов**
   ```bash
   # Проверка использования ресурсов
   kubectl top pod -n postgresql
   kubectl describe node
   ```

---

## 📚 Дополнительные ресурсы

### **PostgreSQL документация:**
- [PostgreSQL Official Docs](https://www.postgresql.org/docs/)
- [PostgreSQL Tutorial](https://www.postgresqltutorial.com/)
- [SQL Commands Reference](https://www.postgresql.org/docs/current/sql-commands.html)

### **Kubernetes + PostgreSQL:**
- [PostgreSQL on Kubernetes](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/)
- [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)

---

**Создано**: $(date)
**PostgreSQL Version**: 15
**Namespace**: postgresql
**Статус**: Готово к обучению! 🎉
