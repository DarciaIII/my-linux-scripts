#!/usr/bin/env python3
import sys
import requests
import json

CONFIG_FILE = "telegram_config.json"

# === Читаем конфиг ===
try:
    with open(CONFIG_FILE, "r", encoding="utf-8") as f:
        config = json.load(f)
        TOKEN = config.get("TELEGRAM_TOKEN")
        CHAT_ID = config.get("TELEGRAM_CHAT_ID")
except FileNotFoundError:
    print(f"Файл {CONFIG_FILE} не найден. Создайте его рядом со скриптом.")
    sys.exit(1)

if not TOKEN or not CHAT_ID:
    print("В конфиге должны быть поля TELEGRAM_TOKEN и TELEGRAM_CHAT_ID.")
    sys.exit(1)

# === Проверяем аргументы ===
if len(sys.argv) < 2:
    print("Использование: python send_telegram.py 'Ваше сообщение'")
    sys.exit(1)

text = " ".join(sys.argv[1:])

# === Отправляем сообщение ===
url = f"https://api.telegram.org/bot{TOKEN}/sendMessage"
payload = {"chat_id": CHAT_ID, "text": text}

response = requests.post(url, data=payload)

if response.status_code == 200:
    print("Сообщение отправлено успешно.")
else:
    print(f"Ошибка: {response.status_code}")
    print(response.text)
