#!/bin/bash
# Скрипт для автоматической сборки и установки ядра Linux 6.17.6
# Пропускает все вопросы (olddefconfig) и подходит для слабых систем

set -e

# --- Параметры ---
KERNEL_VERSION="6.17.6"
CPU_CORES=1          # количество потоков сборки (для слабых машин)
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

# --- Распаковываем исходники ---
if [ ! -d "linux-$KERNEL_VERSION" ]; then
    echo "Распаковываем ядро..."
    tar -xf "$SRC_ARCHIVE"
fi

cd "linux-$KERNEL_VERSION"

# --- Используем текущую конфигурацию, если есть ---
if [ -f /boot/config-$(uname -r) ]; then
    echo "Копируем текущую конфигурацию ядра..."
    cp /boot/confi
