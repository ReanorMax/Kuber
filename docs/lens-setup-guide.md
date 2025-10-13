# Настройка Lens для доступа к Kind кластеру

## 📋 Обзор

Lens - это мощный desktop-клиент для Kubernetes. Этот гайд поможет настроить Lens на Windows для доступа к Kind кластеру, работающему на Linux сервере.

---

## 🔧 Проблема доступа к Kind из внешней сети

Kind по умолчанию настраивает API сервер Kubernetes для доступа только с localhost:
```
127.0.0.1:41917 -> 6443/tcp
```

Это означает, что напрямую с Windows машины подключиться к кластеру **нельзя**.

---

## ✅ Решение: SSH туннель

Лучший и самый безопасный способ - использовать SSH туннель для проброса порта API сервера.

### Способ 1: SSH туннель (рекомендуется)

#### На Windows (PowerShell или CMD):

```powershell
# Создаём SSH туннель (оставьте окно открытым)
ssh -L 6443:127.0.0.1:41917 root@10.19.1.209 -N
```

Параметры:
- `-L 6443:127.0.0.1:41917` - пробрасываем локальный порт 6443 на удалённый 41917
- `root@10.19.1.209` - подключение к серверу
- `-N` - не выполнять команды, только туннель

**Оставьте это окно открытым** пока работаете с кластером!

#### Kubeconfig для Lens (с SSH туннелем):

Создайте файл `C:\Users\<YourUsername>\.kube\config-kind`:

```yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUMvakNDQWVhZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJMU1UQXhNekEyTkRJek5sb1hEVE0xTVRBeE1UQTJOREl6Tmxvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTmtaCjFvN1F1ZVdnSkxrcmt0MHRYZUhBYWhVL2RLVkhVcHBZRXd0ZDAxRXUvcWlMZEtrWll2K0l4aXlYR2VqRm5IZ2YKMUdTUjZiYmdVWXREQURHNnlJam5tQ0hwMW9kVEx6ajZNMlVqMVQzU3pJSEdQdnIvdFgzcjJLZzQzalBwM1BwMgp3VU5SYVFDUDl0YlIvQXVmQ1I3bGMyTXR5ZUhDcy8xMXdnbEJKUFd1clBqMGVnTy9OV3hoSGVtb2FXZTBhd2FLCloyR0toVEJEZ2FXUnAwTnVKL2orZW1NclczeE9uRnhObTcwVjMzZ28yNWFEdTZyMWs0M3NicHNad2tzY1l4Rm0KenIyM093OE9kd3hvWGtMQytXczhGRDJmckNKTFVhU242N203ellyRlREeGlkSWdYK3VTZnhYR01hRTVaWGxLdgp6d3VYVFdXNG1RWlA1dUVscUZjQ0F3RUFBYU5aTUZjd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZOM1dFM3lJUFNuejFZUVB4Nlo4SGxmbXM1V1lNQlVHQTFVZEVRUU8KTUF5Q0NtdDFZbVZ5Ym1WMFpYTXdEUVlKS29aSWh2Y05BUUVMQlFBRGdnRUJBSUVFcWZoMWVZY2RhaXB4MWdmRwpFWnVaNnpYM0pIcC9MRFZ2WSs0aE05Y0JmK0xyS3k5aFpURDNhOVJ2WlpoQno3L2w2dWxIRUxKYXk2aTczNWJuCmYvRGRFZ1g0U1pzNU1aZW93TTZoZXAvR29zakZGVHBiWjExdG9aN3podGhSVEpHa0JpcTlmR1lhcEU4eTZyZXkKdWtsRFAxcnN1TnRKdStQL1FOQWhWb2RhU2RtbkpLMC9QaWhSQUZlSFpTeEtxam5yUFJZakFNeFNuMWMrYVNMTgpXc05oamZBcUJRR3Jkajk0cDFCQ0JxQmUvNzQrWnNKWnhWWUx3RWZmQkh1d1pQbEozdTBIaGRXNXo2NjV4ODA0Cnh3YUFsTnQwWDBZN3Fuakpza1JwZDM4SkNpdkdzdHNSYVpEM0xuUXR1SXBtWk1OMGQ0YlhqZGJaWjJRYjYyaEsKUTkwPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
    server: https://127.0.0.1:6443
  name: kind-learning-cluster
contexts:
- context:
    cluster: kind-learning-cluster
    user: kind-learning-cluster
  name: kind-learning-cluster
current-context: kind-learning-cluster
kind: Config
preferences: {}
users:
- name: kind-learning-cluster
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURJVENDQWdtZ0F3SUJBZ0lJZUg2Tm4wKzlHTGN3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRFd01UTXdOalF5TXpaYUZ3MHlOakV3TVRNd05qUXlNemhhTURReApGekFWQmdOVkJBb1REbk41YzNSbGJUcHRZWE4wWlhKek1Sa3dGd1lEVlFRREV4QnJkV0psY201bGRHVnpMV0ZrCmJXbHVNSUlCSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQXA3ekVxMUhoZzhpa1BQK0wKSy9hVzFHNVpuQy9kVFJaVDBKZS8zM3ZSMSt1R0Q5clc1OTJpQ2VQNkN2K0NERGFCNnk0WHlza0k3aU1wWVRmNgpjNVduWTBrUmxYNUkyQmRKZ0dKbW1sTzJEWUVhaW9tcTVyUkRQYzFxRVNYY1lwbFBiTmI5cGJqOFUrcFltU3VlCks5bUZ4empGbDBzZGhKbk8vRHNKMXIrUGdXMVFiOGJDdzk2enMvR3M0ekdQMEJYMXhiUHZ6UGQrMjBTdG4vNnQKZHlRSHJpWitkWGFSK2U2SUdBVEE5UlJqM01GTExFMC92eHozeUpNU2huTUF2NENSUXQ2VjlUZGNpUGJGbmxjegpqMzZkQlhWTzJCUUwxa3Jwc2ZWU1doWFdLMTNPU3RRaGFBNE8wM0tnTExCOWVPTnBEb1JUMVFwT2MvdnpiN2FrCmE0b1hTUUlEQVFBQm8xWXdWREFPQmdOVkhROEJBZjhFQkFNQ0JhQXdFd1lEVlIwbEJBd3dDZ1lJS3dZQkJRVUgKQXdJd0RBWURWUjBUQVFIL0JBSXdBREFmQmdOVkhTTUVHREFXZ0JUZDFoTjhpRDBwODlXRUQ4ZW1mQjVYNXJPVgptREFOQmdrcWhraUc5dzBCQVFzRkFBT0NBUUVBa0VBZ0RaNFlTaTVQV2lPY3JEc1paV0g3Qng1eVY1cVBzWWkwCjZRd09HVWRValkxYTh0U0h0Y3NrQVp1TEFJSW1FTUZnT2VjVDZmdW1FREFtcXprYjIvRXlBRVNVeEhIYUkwUGcKcDNwY3ZrMEhldmpuNFFxTFZqeXRPZnpSdEsxVGo4Z1JwV3dFSHh4dEsrNkMwYnNzbmovM0dYK0hoNWVRUUp3RQpGRk1Fb3loMG9iZ2VSTHY0cmNqT1lnQXNDcy91bXUrSnp5Q2dnMjF6WkUwS2l3Z3JZcjdJVFVZWmtBMVZkSDFICjQ4QkJ5Qmhoc21iU1JGaC95eDloWWcxaElFWUFFSnpaOGtGcnpwcTBYb1FJSVlXMlJRSjlpbGNRQ0ZydjBLTG0Ka0RJMExUajYwR0FId2QwVVRxMXQ5cHlQZFFxWHAxazhQV2FPYlF4NzNOUlVxd0hnYnc9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
    client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcFFJQkFBS0NBUUVBcDd6RXExSGhnOGlrUFArTEsvYVcxRzVabkMvZFRSWlQwSmUvMzN2UjErdUdEOXJXCjU5MmlDZVA2Q3YrQ0REYUI2eTRYeXNrSTdpTXBZVGY2YzVXblkwa1JsWDVJMkJkSmdHSm1tbE8yRFlFYWlvbXEKNXJSRFBjMXFFU1hjWXBsUGJOYjlwYmo4VStwWW1TdWVLOW1GeHpqRmwwc2RoSm5PL0RzSjFyK1BnVzFRYjhiQwp3OTZ6cy9HczR6R1AwQlgxeGJQdnpQZCsyMFN0bi82dGR5UUhyaVorZFhhUitlNklHQVRBOVJSajNNRkxMRTAvCnZ4ejN5Sk1TaG5NQXY0Q1JRdDZWOVRkY2lQYkZubGN6ajM2ZEJYVk8yQlFMMWtycHNmVlNXaFhXSzEzT1N0UWgKYUE0TzAzS2dMTEI5ZU9OcERvUlQxUXBPYy92emI3YWthNG9YU1FJREFRQUJBb0lCQVFDaU5pa3pUSUg4UWNLaQp3clpDRTd3VlA0b2xReHlPZWZNZ0hFQ1B6VnhIcFJzR3BpbUNIWkdnWXZuaVBPbjFDWmxtYURMV0JzZytFMzdtCjU0MnF6YVVNblJNR01SUWM5Wmc5TWV2cmZ0emwvbDQrYjVmNGQ0YzNjemtKMEVWcWpMeUVrdnpFa1RwanBKTjkKdlBLL2tTS1FZTlNrMVIxOHFJbkUzd3RLeEFIeHRNWnFCc0JOSzBjUEFTcGFvZk0wVXdJUzkrM0FCUkkrVUZieApHL1NHZ0VTeXpMT2FpYlNuZFhlVm4wRTRxK29ici9qZ2RBdHpqR2RObUhEdU04NUZ4MGlRMW93L3NSMW85OEV4Cjh5NlNmMjA3L1lJYlVobGxPOU93c0xhSzNVLzVPSnFLY2crRFFhWTQrdzdKWTZQNVJIZWFUOXVlU0lDYjF6eDIKQmxUaTBPNXBBb0dCQU5JQWlhaUFBUFpSbndZWmMzeFVCZGVBOUtpbndVY05CcU5ja1NsYXdPaHlWM0o1R1IzMwozdW5Cek1QTUJqbW4zMkFGQWNqMEZzM0R1T0Y1a0pRVXF5OVAzenFUOXBSZnpSS0cxTXBFQ3Y1Rk5VUkN2WnVKCldtQWNyNmFiUHBhVCs1MTdnaE5NK2prNk9wRHg4QjFlS3F1NE5TaGR4ZUN1dHE2RTJobmZlUWtYQW9HQkFNeDYKVVZSeVptMWp0aUlHem9aTnJOOUJtTGRkTzZNNlpTYXp0Um5xditZZFBmcTFmS25wU0tIbk1UdGJiYWhuRXUvTQpBdzZFYXlBK2RBRWVMNGd2TmJldGlzRmcwOVNpT1FndENZR1VmVTZ0MmpZWFEzZXBxdnhjU3ZNQisxOUQyWEpXCnFFMHRiMnd0OEhIRTl3dVhaVUxFVE9abThLemN4WWZSam04NGtWNmZBb0dCQUs4ZmU2eGtjbWoyeitKS1B5QWoKQVd3aFFlV1RYMzVjd25oZ3JUMExUV3VLVHBwTG1rSi9mZ2o1Y0VTblUxbXBRSUhXS3hMbFdrN2xOTHZ5b0RxYwpzZFNXaXRWU3BvSTlFY3F0WGEzKzZCdjZvdHoxdXlDRmZqUkFOOHA4RThtR1JvR2hpV3VHK2ZQWE54ZkFhamhUCldzb3dwME91VDJGNjBTVGY3UEUraHJTcEFvR0JBSXZNcVNSS1h0czFUQVh4ajJ2bFdXYitpekg2alZhcEN4VXQKMG9qWXBjRG5oME9NcDZIbmZDQXRWOHlVVXVITEx2aENER2oxZ2VSMnJvdEJIeEJGN3IwWTZvQVIrbUlyVTBEUwp3ZWdWSktNUlc5cVZoeXdlRldnYWxhZVZXRTZtcmRsdGcvM1lMWkRSeTgyTTg3YTZHS0pRWVo4NURCMnpoMTIzCm1XRlRWSmhUQW9HQVZjYyszNi9RaytMeDllRTVTK2F0VzhYZzZ1MWd6cGd3Uk9OekZOQlNQa2w2ZitMcXUvMXkKYU1LRndyajNWelowaE9NOUVnaE83UGttSEJ6NHBhNlE1a3VIUFpQTFpjbkp2YzJHTUR1anhaR0tCaThHV29tMwpscERFbnpKczZBc0pxWHY2ay9aR3dHTnh6eThEV01YU1A2VHhqN3p6ZFlBZDR6aFMzU3lEYXZzPQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo=
```

**Обратите внимание**: `server: https://127.0.0.1:6443` - теперь указывает на локальный порт, который туннелирован на сервер!

---

### Способ 2: Пересоздание Kind кластера с внешним доступом (не рекомендуется)

Можно изменить Kind конфиг для проброса API сервера наружу, но это **небезопасно для production**:

```yaml
# kind-config.yaml
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 6443
    hostPort: 6443
    listenAddress: "0.0.0.0"  # ⚠️ Открывает доступ всем!
```

**Недостатки**:
- ⚠️ API сервер доступен всем в сети
- ⚠️ Риск для безопасности
- ⚠️ Не подходит для production

---

## 📦 Установка и настройка Lens

### Шаг 1: Установка Lens на Windows

1. Скачайте Lens:
   - **Lens Desktop**: [https://k8slens.dev/](https://k8slens.dev/)
   - **OpenLens** (бесплатная альтернатива): [https://github.com/MuhammedKalkan/OpenLens](https://github.com/MuhammedKalkan/OpenLens)

2. Установите приложение

### Шаг 2: Настройка SSH туннеля

1. Откройте PowerShell или CMD
2. Запустите SSH туннель:
   ```powershell
   ssh -L 6443:127.0.0.1:41917 root@10.19.1.209 -N
   ```
3. Оставьте окно открытым

### Шаг 3: Создание kubeconfig

1. Создайте директорию (если нет):
   ```powershell
   mkdir C:\Users\<YourUsername>\.kube
   ```

2. Создайте файл `C:\Users\<YourUsername>\.kube\config` с содержимым выше

### Шаг 4: Подключение в Lens

1. Откройте Lens
2. Lens автоматически обнаружит кластер из `~/.kube/config`
3. Или вручную: **File → Add Cluster** → вставьте kubeconfig
4. Кластер появится в списке как **kind-learning-cluster**

### Шаг 5: Проверка подключения

1. Кликните на кластер в Lens
2. Вы должны увидеть:
   - Все Nodes (1 control-plane)
   - Namespaces (default, kube-system, monitoring, etc.)
   - Pods, Services, Deployments

---

## 🎯 Использование Lens

### Основные возможности:

1. **Просмотр ресурсов**:
   - Workloads → Pods, Deployments, StatefulSets
   - Network → Services, Ingresses
   - Config → ConfigMaps, Secrets
   - Storage → PVCs, Storage Classes

2. **Логи**:
   - Кликните на Pod → Logs
   - Реальное время, поиск, фильтрация

3. **Терминал**:
   - Кликните на Pod → Shell
   - Прямой доступ к контейнеру

4. **Редактирование**:
   - Правая кнопка мыши → Edit
   - YAML редактор с валидацией

5. **Мониторинг**:
   - CPU и Memory usage
   - Графики ресурсов

---

## 🔍 Альтернативы SSH туннелю

### 1. kubectl port-forward (временно)

```bash
# На сервере
kubectl proxy --address='0.0.0.0' --accept-hosts='.*'
```

Затем в Lens используйте `http://10.19.1.209:8001`

**Недостатки**: Нужно каждый раз запускать, менее безопасно

### 2. VPN

Если у вас есть VPN между Windows и сервером, можно использовать оригинальный kubeconfig без изменений.

---

## ⚠️ Troubleshooting

### Проблема: "Unable to connect to cluster"

**Решение**:
1. Проверьте, что SSH туннель активен
2. Проверьте, что порт 6443 не занят на Windows:
   ```powershell
   netstat -ano | findstr :6443
   ```
3. Перезапустите SSH туннель

### Проблема: "Certificate error"

**Решение**:
- Убедитесь, что скопировали полный `certificate-authority-data` из оригинального kubeconfig
- Проверьте, что сертификаты не содержат лишних пробелов

### Проблема: "Context deadline exceeded"

**Решение**:
1. Проверьте подключение к серверу: `ping 10.19.1.209`
2. Проверьте, что Kind кластер запущен:
   ```bash
   docker ps | grep learning-cluster
   ```
3. Проверьте порт API: `curl -k https://127.0.0.1:41917` (на сервере)

---

## 📊 Сравнение способов доступа

| Способ | Безопасность | Удобство | Скорость |
|--------|--------------|----------|----------|
| SSH туннель | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| kubectl proxy | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| Внешний порт Kind | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| VPN | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |

---

## ✅ Итого

1. **Лучший способ**: SSH туннель + Lens
2. **Безопасно**: Без открытия портов наружу
3. **Удобно**: Один раз настроил - работает всегда
4. **Функционально**: Полный доступ ко всем возможностям кластера

Теперь вы можете работать с Kubernetes кластером из удобного GUI на Windows!

