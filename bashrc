# ===============================
# 🌈 УЛУЧШЕННЫЙ .bashrc (с ss вместо netstat)
# ===============================

# ----- Базовые настройки -----
# Загружаем системный bashrc, если он существует
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Включаем цветной вывод для ls, grep и т.д.
alias ls='ls --color=auto'     # Цветной вывод файлов
alias grep='grep --color=auto' # Подсвечивает совпадения
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# ----- Удобные алиасы -----
alias ll='ls -lh'         # Показать файлы с размерами в читаемом виде
alias la='ls -A'          # Показать все файлы, включая скрытые
alias l='ls -CF'          # Компактный вывод по колонкам
alias ..='cd ..'          # Перейти на один уровень выше
alias ...='cd ../..'      # Перейти на два уровня выше
alias c='clear'           # Очистить экран
alias h='history'         # Показать историю команд
alias cls='clear'         # Альтернатива clear
alias cp='cp -iv'         # Копировать с подтверждением и показом
alias mv='mv -iv'         # Перемещать с подтверждением и показом
alias rm='rm -iv'         # Удалять с подтверждением и показом
alias df='df -h'          # Показать использование дисков (удобный формат)
alias du='du -h'          # Показать размер папок (удобный формат)
alias free='free -h'      # Память в читаемом виде

# ----- Сеть -----
alias myip='curl ifconfig.me'         # Показать внешний IP
alias pingg='ping 8.8.8.8'            # Проверить соединение с Google DNS
alias ports='sudo ss -tulnp'          # Показать открытые порты и процессы
alias connections='ss -t -a'          # Показать все TCP соединения
alias listen='ss -ltn'                # Показать все слушающие TCP порты
alias udp='ss -lun'                   # Показать все слушающие UDP порты
alias netstat='ss -tulnp'             # Прозрачная замена старого netstat

# ----- Git -----
alias gst='git status'         # Проверить статус репозитория
alias gpl='git pull'           # Скачать последние изменения
alias gps='git push'           # Отправить коммиты на сервер
alias gcm='git commit -m'      # Создать коммит с сообщением
alias gbr='git branch'         # Показать ветки
alias gco='git checkout'       # Переключиться на другую ветку

# ----- Навигация -----
alias dev='cd ~/projects'      # Переход в каталог проектов
alias dl='cd ~/Downloads'      # Переход в каталог загрузок
alias docs='cd ~/Documents'    # Переход в каталог документов

# ----- Информация о системе -----
alias meminfo='free -m'        # Память в мегабайтах
alias cpuinfo='lscpu'          # Информация о процессоре
alias disks='lsblk -f -e7'     # Список реальных дисков и ФС
alias update='sudo apt update && sudo apt upgrade -y'  # Обновить систему
alias cleanup='sudo apt autoremove -y && sudo apt clean' # Очистить кэш и мусор

# ----- Цветной prompt -----
# Пример: user@host:/путь$
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# ----- История -----
HISTSIZE=5000                        # Количество команд в истории
HISTCONTROL=ignoredups:erasedups     # Убираем дубликаты
shopt -s histappend                  # Добавлять в историю, а не перезаписывать
PROMPT_COMMAND="history -a; history -n; $PROMPT_COMMAND" # Автосохранение истории

# ----- Автодополнение -----
# Включаем bash_completion, если доступен (для git, ssh и др.)
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# ----- Полезные функции -----

# 🧹 Очистка системы
cleanup_system() {
    echo "🧹 Cleaning system..."
    sudo apt autoremove -y
    sudo apt clean
    sudo journalctl --vacuum-time=3d
    echo "✅ Done."
}

# 🔍 Поиск файла по имени (пример: f config)
f() {
    find . -iname "*$1*"
}

# 📦 Показать 20 самых больших файлов/папок
biggest() {
    du -ah . | sort -rh | head -n 20
}

# 🕒 Приветствие при входе
echo "Добро пожаловать, $USER!"
echo "⏰ Сегодня: $(date)"
echo "📂 Текущая директория: $(pwd)"
echo

# ===============================
# Конец .bashrc
# ===============================
