#!/bin/bash
# обычный пользоваетль создается с правами толко на чтение readAnyDatabase 
# Функция генерации случайного крепкого пароля
generate_password() {
  openssl rand -base64 8 | tr -d '\n'
}

echo "=== Создание мониторинг-пользователя в MongoDB Replica Set ==="
echo "Роли: readAnyDatabase + clusterMonitor"
echo "Доступ: чтение всех БД + мониторинг кластера (rs.status(), serverStatus и т.д.)"
echo

# 1. Имя контейнера Primary
read -p "Имя контейнера Primary (например, mongo_claster1): " PRIMARY_CONTAINER
if [ -z "$PRIMARY_CONTAINER" ]; then
  echo "Ошибка: имя контейнера не может быть пустым."
  exit 1
fi

# 2. Имя пользователя (по умолчанию — monitor)
read -p "Имя пользователя [monitor]: " USERNAME
USERNAME=${USERNAME:-monitor}  # если пусто — будет "monitor"

# Генерируем пароль
PASSWORD=$(generate_password)

echo
echo "Создаётся пользователь '$USERNAME'..."
echo "Случайный пароль: $PASSWORD"
echo "!!! Скопируйте его сейчас — он больше не будет показан !!!"
echo

# Создаём пользователя с нужными ролями
docker exec -it "$PRIMARY_CONTAINER" mongo --quiet <<EOF
use admin
db.createUser({
  user: "$USERNAME",
  pwd: "$PASSWORD",
  roles: [ "readAnyDatabase", "clusterMonitor" ]
})
print("Мониторинг-пользователь '$USERNAME' успешно создан или обновлён.")
EOF

echo
echo "Готово!"
echo
echo "Строка подключения для мониторинга:"
echo "mongodb://$USERNAME:$PASSWORD@185.246.222.252:27017,150.241.106.82:27017,150.241.106.82:27018/admin?replicaSet=rs0&authSource=admin&readPreference=secondaryPreferred"
echo
echo "Рекомендации по readPreference:"
echo "  - secondaryPreferred — читать с Secondary (снимает нагрузку с Primary)"
echo "  - primary — только с Primary (для актуальности данных)"
echo
echo "Пароль ещё раз: $PASSWORD"
echo
echo "Сохраните его в безопасном месте (KeePass, Vault и т.д.)"
