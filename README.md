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
- Задайте обовʼязкові параметри `IT_ARMY_USER_ID`, `VPN_USER` та `VPN_PASSWORD`. Також можете задаті і інші (не обовʼязкові параметри, вони закоментовані)
- Покладіть ваші .ovpn файли в директорію `openvpn/`

> `VPN_USER` та `VPN_PASSWORD` це логін та пароль вашого VPN сервісу для підключення до VPN.

## Запуск
Далі ви будете працювати з docker-compose, для цього ви повинні знаходитись в тій директорії де знаходиться docker-compose.yml фалй.

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