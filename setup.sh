#!/bin/bash

# 1. Обновление репозиториев
sudo xbps-install -Syu

# 2. Установка софта (Графика AMD, Sway, Dev-стек, Реверс)
# Убрали Steam и Вулкан для легкости, добавим их позже вручную
sudo xbps-install -y sway foot wl-clipboard wofi neovim git nodejs \
base-devel nasm python3 gdb clang-tools-extra rizin Cutter \
qemu libvirt virt-manager unzip font-jetbrains-mono-nerd xclip

# 3. Настройка групп и сервисов
sudo usermod -aG video,input,libvirt $(whoami)
sudo ln -s /etc/sv/dbus /var/service/
sudo ln -s /etc/sv/libvirtd /var/service/

# 4. Создание минималистичного конфига Sway (управление без мышки)
mkdir -p ~/.config/sway
cat <<EOF > ~/.config/sway/config
set \$mod Mod4
set \$term foot
font pango:JetBrainsMono Nerd Font 10
output * bg #282828 solid_color
xwayland enable

# Горячие клавиши
bindsym \$mod+Return exec \$term
bindsym \$mod+d exec wofi --show run
bindsym \$mod+Shift+q kill
bindsym \$mod+h focus left
bindsym \$mod+j focus down
bindsym \$mod+k focus up
bindsym \$mod+l focus right

# Настройка плавающих окон для инструментов
for_window [class="Cutter"] floating enable
EOF

# 5. Подготовка Neovim (AstroNvim)
# Просто напомню: после запуска Neovim вставь свой конфиг в ~/.config/nvim
mkdir -p ~/.config/nvim

echo "--- УСТАНОВКА ЗАВЕРШЕНА ---"
echo "Теперь введи 'sway' и начни работать."

