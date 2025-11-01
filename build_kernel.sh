#!/bin/bash
# Скрипт для автоматической сборки и установки ядра Linux 6.17.6
# Подходит для слабых машин (1 ГБ RAM) и VM

set -e

# --- Параметры ---
KERNEL_VERSION="6.17.6"
CPU_CORES=1          # для слабых машин, на нормальных можно $(nproc)
WORKDIR="$HOME/kernel_build"
SRC_ARCHIVE="linux-$KERNEL_VERSION.tar.xz"
SRC_URL="https://cdn.kernel.org/pub/linux/kernel/v6.x/$SRC_ARCHIVE"

# --- Создать рабочую директорию ---
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# --- Скачиваем исходники, если их нет ---
if [ ! -f "$SRC_ARCHIVE" ]; then
    echo "Скачиваем исходники ядра $KERNEL_VERSION..."
    wget "$SRC_URL"
fi

# --- Распаковываем ---
if [ ! -d "linux-$KERNEL_VERSION" ]; then
    echo "Распаковываем ядро..."
    tar -xf "$SRC_ARCHIVE"
fi

cd "linux-$KERNEL_VERSION"

# --- Используем текущую конфигурацию (если есть) ---
if [ -f /boot/config-$(uname -r) ]; then
    echo "Копируем текущую конфигурацию ядра..."
    cp /boot/config-$(uname -r) .config
    make oldconfig
else
    echo "Нет старой конфигурации. Используем дефолт..."
    make defconfig
fi

# --- (Опционально) меню настройки ---
# Uncomment следующую строку, если хотите вручную изменить опции
# make menuconfig

# --- Сборка ядра ---
echo "Собираем ядро..."
make -j$CPU_CORES

# --- Установка модулей и ядра ---
echo "Устанавливаем модули..."
sudo make modules_install
echo "Устанавливаем ядро..."
sudo make install

# --- Обновление GRUB ---
echo "Обновляем GRUB..."
if command -v update-grub &> /dev/null; then
    sudo update-grub
elif command -v grub2-mkconfig &> /dev/null; then
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
else
    echo "GRUB не найден. Обновите его вручную."
fi

echo "Сборка и установка ядра $KERNEL_VERSION завершены!"
echo "Перезагрузите систему и выберите новое ядро в меню GRUB."
