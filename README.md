## Що це?
Це mhddos запакований в Docker контейнер разом з OpenVPN та скриптом автоматичного перезапуску в рандомний проміжок часу (від 10 хвилин до одної години). Під час запуску контейнер обере рандомний .ovpn файл для підключення до VPN провайдера, таким чином трафік буде в різні напрямки з різною періодичністю.
Ціллю було зробити щось схоще на x100, але на базі mhddos.
Робота триває.

## Підготовка
Встановіть Docker та docker-compose. Це просто, не буду розписувати.
Для Ubuntu це робиться так
```
apt update && apt install -y docker.io docker-compose
```
Для інших ОС дивіться [на офіційному сайті](https://docs.docker.com/engine/install/).

Скачайте цей репозиторій на сервер.
```
git clone https://github.com/tbinre/docker-mhddos-openvpn.git

# Або просто скачайте zip
curl -sL https://github.com/tbinre/docker-mhddos-openvpn/archive/refs/heads/main.zip -o mhddos_docker.zip
```

## Налаштування
- Скопіюйте (або перейменуйте) файл `.env.example` в `.env`
- Задайте обовʼязковий параметр `IT_ARMY_USER_ID`. Також можете задаті і інші (не обовʼязкові параметри, вони закоментовані)
- Покладіть ваші .ovpn файли і файл `auth.txt` який містить логін і пароль в директорію `openvpn/provider-name/`. (provider-name - довільна назва, треба для підтримки декількох наборів ovpn файлів від різних VPN провайдерів та/або для різних аккаунтів)

> `auth.txt` файл повинен містити 2 строки, в першій логін, а в другій пароль вашого VPN сервісу для підключення до VPN.
>
> Ось так повинна виглядати директорія `openvpn/`
> ```
> openvpn/
> ├── provider-1
> │   ├── auth.txt
> │   ├── albania.ovpn
> │   ├── algeria.ovpn
> │   ├── ...
> └── provider-2
>     ├── auth.txt
>     ├── de.ovpn
>     ├── fr.ovpn
>     ├── ...
> ```

> Pro Tip: Для того щоб тимчасово "вимкнути" використання якогось з VPN провайдерів - перейменуйте директорію в таку, щоб назва починалась з крапки (Приклад: `.provider-1`)

## Запуск
Далі ви будете працювати з docker-compose, для цього ви повинні знаходитись в тій директорії де знаходиться docker-compose.yml файл.

### Запуск скриптом
Для зручності був доданий скрипт який автоматично збирає та запускає контейнер у фоні. Його основна мета це динамічно налаштувати hostname контейнеру базуючись на hostname хост машини.
```
./build_and_run.sh
```

### Запуск вручну

Зберіть білд образу
```
docker-compose build
```
Запускайте 
```
# Запуск в поточному вікні терміналу
docker-compose up

# Або запуск в фоні
docker-compose up -d

# Завершити роботу контейнеру
docker-compose down
```

Також можна білдити при кожному запуску
```
# В поточному терміналі
docker-compose up --build

# В фоні
docker-compose up -d --build
```

Подвитись процесс роботи (логи)
```
docker-compose logs -f
```

## Опис налаштуваннь
Всі доступні для налаштування змінні перелічені в `.env.example` файлі.
- `DISABLE_VPN` - режим роботи без VPN.
- `MHDDOS_USE_IP_PERCENTAGE` - Опція mhddos, процент використання власного IP для атаки. За замовчуванням - 5 в стандартному режимі (з VPN, використовується IP VPN) та 0 в режимі коли VPN виключений.
- `MHDDOS_LANG` - Мова mhddos. (en - за замовчуванням)
- `MHDDOS_COPIES` - Опція mhddos, кількість запущенних копій. (auto - за замовчуванням)
- `MHDDOS_THREADS` - Опція mhddos, кількість тредів на одну копію. (auto за замовчуванням)
- `BASE_HOSTNAME` - це базова частина хостнейму з якої буде генеруватись хостнейм контейнера. При використанні скрипту `build_and_run.sh` буде автоматично взятий хостнейм хост машини.
- `SESSION_TIME_MIN` - Мінімальний час в секундах на протязі якого контейнер буде працювати до автоматичного перезапуску. За замовчуванням 2700 секунд (45 хв.)
- `SESSION_TIME_MAX` - Максимальний проміжок часу на протязі якого контейнер буде працювати до автоматичного перезапуску. За замовчуванням 10800 секунд (3 год.)

## Оновлення з 0.1 (beta) версії до поточної
Процес оновлення з попередньої версії (0.1, без пітримки декількох VPN провайдерів) до поточної простий і складається з декількох кроків.
1. В директорії `openvpn/` створіть піддиректорію для вашого набору .ovpn файлів та перемістіть ці файли в створену директорію (наприклад `openvpn/provider-1/`)
2. В новостворенній директорії створіть файл `openvpn/provider-1/auth.txt` який містить логін та пароль для цього VPN провайдера. (Перша строка - логін, друга - пароль)
3. Видаліть `VPN_USER` та `VPN_PASSWORD` з вашого `.env` файлу. Ці параметри більше не підтримуються.
4. Видаліть попередній контейнер `docker-compose down`, зберіть новий та запустіть `docker-compose up --build`

## Інше
Якщо вам треба попередня версія (без підтримки різних VPN провайдерів) ії можна завантажити за [цим](https://github.com/tbinre/docker-mhddos-openvpn/archive/refs/tags/0.1.zip) посиланням. Але вона не має додатковоії перевірки чи змінилася IP адреса після підключення до VPN, як виявилось це дуже потрібно.