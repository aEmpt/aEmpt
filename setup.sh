#!/bin/bash
set -e

# 1. Обновление системы
sudo xbps-install -Syu

# 2. Установка софта (Добавлен mesa-dri для графики AMD и seatd для сессий)
# Пакет xorg-server-xwayland возвращен в зависимости, так как Cutter/GDB могут использовать X11 плагины.
sudo xbps-install -y \
    sway foot wofi wl-clipboard seatd mesa-dri xorg-server-xwayland \
    git neovim base-devel python3 nodejs strace \
    nasm clang-tools-extra llvm cppcheck gdb rizin cutter \
    qemu libvirt virt-manager

# 3. Настройка сервисов и прав групп (Критично для Void Linux)
# Добавляем пользователя в группу _seatd для доступа к видеокарте без root прав
sudo usermod -aG video,input,libvirt,_seatd $(whoami)

# Активация системных сервисов через runit
sudo ln -sf /etc/sv/dbus /var/service/
sudo ln -sf /etc/sv/seatd /var/service/
sudo ln -sf /etc/sv/libvirtd /var/service/

# 4. Автоматизация экспорта переменных и правильного запуска Sway
# Так как elogind убран для легковесности, прописываем создание XDG_RUNTIME_DIR вручную
cat << 'EOF' >> ~/.bash_profile

# Настройка Wayland-сессии для Void Linux (без systemd)
if [ -z "$XDG_RUNTIME_DIR" ]; then
    export XDG_RUNTIME_DIR="/tmp/runtime-$(whoami)"
    mkdir -p "$XDG_RUNTIME_DIR"
    chmod 700 "$XDG_RUNTIME_DIR"
fi

# Автозапуск Sway при логине на первой TTY-консоли
if [ "$(tty)" = "/dev/tty1" ]; then
    exec dbus-run-session sway
fi
EOF

# 5. Установка GEF для GDB (Интерфейс под реверс)
curl -sL githubusercontent.com > ~/.gdbinit-gef.py
echo "source ~/.gdbinit-gef.py" > ~/.gdbinit

# 6. Создание минималистичного темного конфига Sway
mkdir -p ~/.config/sway ~/.config/foot

# Конфиг терминала Foot
cat << 'EOF' > ~/.config/foot/foot.ini
[colors]
background=1a1b26
foreground=a9b1d6
regular0=32344a
regular1=f7768e
regular2=9ece6a
regular3=e0af68
regular4=7aa2f7
regular5=bb9af7
regular6=7dcfff
regular7=a9b1d6
EOF

# Конфиг Sway
cat << 'EOF' > ~/.config/sway/config
set $mod Mod4
set $term foot

# Total Dark Minimal оформление
default_border pixel 1
default_floating_border pixel 1
gaps inner 8
gaps outer 4
smart_gaps on
smart_borders on

client.focused          #7aa2f7 #1a1b26 #a9b1d6 #7aa2f7 #7aa2f7
client.focused_inactive #32344a #1a1b26 #787c99 #32344a #32344a
client.unfocused        #32344a #1a1b26 #787c99 #32344a #32344a

output * bg #1a1b26 solid_color

# Горячие клавиши
bindsym $mod+Return exec $term
bindsym $mod+d exec wofi --show run
bindsym $mod+Shift+q kill

# Vim-style навигация
bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right

bindsym $mod+Shift+h move left
bindsym $mod+Shift+j move down
bindsym $mod+Shift+k move up
bindsym $mod+Shift+l move right

# Правила для инструментов реверса
for_window [app_id="cutter"] floating enable
for_window [app_id="virt-manager"] floating enable
EOF

echo -e "\n\033[0;32m✅ Скрипт успешно выполнен!\033[0m"
echo -e "\033[1;33mОБЯЗАТЕЛЬНО: Перезагрузите компьютер (sudo reboot), чтобы применились группы и запустился seatd.\033[0m"
