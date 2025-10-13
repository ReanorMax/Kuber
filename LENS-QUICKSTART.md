# 🚀 Быстрый старт с Lens для Windows

> 📚 **Навигация**: [← Назад к INDEX](docs/INDEX.md) | [🏠 Главная](README.md) | [🔐 SSH туннель подробно](docs/ssh-tunnel-explained.md) | [🖥️ Lens детальная настройка](docs/lens-setup-guide.md)

## 📝 Что нужно сделать (3 шага)

### Шаг 1: Установить Lens на Windows

Скачайте и установите одну из версий:
- **Lens Desktop**: https://k8slens.dev/
- **OpenLens** (бесплатная): https://github.com/MuhammedKalkan/OpenLens/releases

### Шаг 2: Создать SSH туннель

Откройте PowerShell или CMD на Windows и выполните:

```powershell
ssh -L 6443:127.0.0.1:41917 root@10.19.1.209 -N
```

**Важно**: Оставьте это окно открытым, пока работаете с кластером!

### Шаг 3: Импортировать kubeconfig в Lens

#### Вариант A: Автоматический импорт

1. Скопируйте файл `kubeconfig-for-windows.yaml` с сервера на Windows
2. Переименуйте в `config` (без расширения)
3. Поместите в `C:\Users\<YourUsername>\.kube\config`
4. Lens автоматически обнаружит кластер

#### Вариант B: Ручной импорт

1. Откройте Lens
2. **File → Add Cluster**
3. Скопируйте содержимое файла `kubeconfig-for-windows.yaml`
4. Вставьте в Lens
5. Нажмите **Add Cluster**

---

## ✅ Готово!

Теперь в Lens вы увидите кластер **kind-learning-cluster** и сможете:

- 👀 Просматривать все ресурсы (Pods, Services, Deployments и т.д.)
- 📊 Мониторить использование CPU и памяти
- 📝 Просматривать логи в реальном времени
- 💻 Открывать терминал в любом поде
- ✏️ Редактировать YAML манифесты
- 🔍 Диагностировать проблемы

---

## 📚 Дополнительно

**Kubernetes Dashboard** также доступен:
```bash
# На сервере запустите:
./scripts/access-dashboard.sh

# Откройте в браузере:
https://10.19.1.209:8443
```

**Другие GUI инструменты**: см. `docs/gui-tools-comparison.md`

**Подробная инструкция**: см. `docs/lens-setup-guide.md`

---

## ⚠️ Troubleshooting

**Проблема**: "Unable to connect"
- **Решение**: Проверьте, что SSH туннель активен

**Проблема**: "Certificate error"
- **Решение**: Используйте точное содержимое `kubeconfig-for-windows.yaml`

**Проблема**: SSH туннель не работает
- **Решение**: Проверьте подключение: `ping 10.19.1.209`

