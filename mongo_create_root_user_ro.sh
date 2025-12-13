#!/bin/bash

# Функция генерации случайного пароля (32 байта base64 → ~43 символа)
generate_password() {
  openssl rand -base64 32 | tr -d '\n'
}

# Справка
show_help() {
  echo "=== Создание пользователя в MongoDB Replica Set ==="
  echo
  echo "Использование:"
  echo "  ./create_mongo_user.sh <тип> <имя_контейнера_primary> [имя_пользователя]"
  echo
  echo "Типы пользователей:"
  echo "  root      — полный администратор кластера (роль 'root')"
  echo "  monitor   — мониторинг: чтение всех БД + clusterMonitor"
  echo
  echo "Примеры:"
  echo "  ./create_mongo_user.sh root mongo_claster1"
  echo "  ./create_mongo_user.sh root mongo_claster1 myroot"
  echo "  ./create_mongo_user.sh monitor mongo_claster1"
  echo "  ./create_mongo_user.sh monitor mongo_claster1 mongomonitor"
  echo
  echo "Если имя пользователя не указано — будет 'root' или 'monitor' соответственно."
  exit 1
}

# Проверка параметров
if [ $# -lt 2 ]; then
  show_help
fi

USER_TYPE="$1"          # root или monitor
PRIMARY_CONTAINER="$2"  # имя контейнера Primary
USERNAME="$3"           # опционально

# Валидация типа
if [ "$USER_TYPE" != "root" ] && [ "$USER_TYPE" != "monitor" ]; then
  echo "Ошибка: тип пользователя должен быть 'root' или 'monitor'."
  show_help
fi

# Имя пользователя по умолчанию
if [ -z "$USERNAME" ]; then
  USERNAME="$USER_TYPE"
fi

# Генерация пароля
PASSWORD=$(generate_password)

echo "=== Создание пользователя '$USERNAME' ($USER_TYPE) ==="
echo "Контейнер Primary: $PRIMARY_CONTAINER"
echo "Случайный пароль: $PASSWORD"
echo "!!! Скопируйте пароль сейчас — он больше не будет показан !!!"
echo

# Определяем роли
if [ "$USER_TYPE" = "root" ]; then
  ROLES='[ "root" ]'
  echo "Роли: root (полный администратор кластера)"
else
  ROLES='[ "readAnyDatabase", "clusterMonitor" ]'
  echo "Роли: readAnyDatabase + clusterMonitor (чтение всех БД + мониторинг)"
fi

# Создаём пользователя
docker exec -it "$PRIMARY_CONTAINER" mongo --quiet <<EOF
use admin
db.createUser({
  user: "$USERNAME",
  pwd: "$PASSWORD",
  roles: $ROLES
})
print("Пользователь '$USERNAME' успешно создан или обновлён.")
EOF

echo
echo "Готово!"
echo

if [ "$USER_TYPE" = "root" ]; then
  echo "Для админ-доступа:"
  echo "docker exec -it $PRIMARY_CONTAINER mongo -u $USERNAME -p $PASSWORD --authenticationDatabase admin"
else
  echo "Строка подключения для мониторинга:"
  echo "mongodb://$USERNAME:$PASSWORD@185.246.222.252:27017,150.241.106.82:27017,150.241.106.82:27018/admin?replicaSet=rs0&authSource=admin&readPreference=secondaryPreferred"
  echo "(readPreference=secondaryPreferred — читает с Secondary, снимает нагрузку с Primary)"
fi

echo
echo "Пароль ещё раз: $PASSWORD"
echo "Сохраните его в безопасном месте!"
