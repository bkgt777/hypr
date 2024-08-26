#!/bin/bash

# Mise à jour du système
sudo pacman -Syu --noconfirm

# Installation des dépendances et outils essentiels
sudo pacman -S --noconfirm \
    git \
    base-devel \
    cmake \
    ninja \
    make \
    gcc \
    wayland \
    wayland-protocols \
    wlroots \
    qt5-wayland \
    qt6-wayland \
    cairo \
    pango \
    gdk-pixbuf2 \
    xorg-xwayland \
    xdg-desktop-portal-wlr \
    polkit \
    libinput \
    kitty \
    thunar \
    firefox \
    mousepad \
    feh \
    zathura \
    file-roller \
    pipewire \
    pipewire-alsa \
    pipewire-pulse \
    pipewire-jack \
    pavucontrol \
    mpv \
    networkmanager \
    network-manager-applet \
    openvpn \
    networkmanager-openvpn \
    ufw \
    gufw \
    rofi \
    waybar \
    dunst \
    flameshot \
    font-manager \
    htop \
    blueman \
    bluez \
    bluez-utils \
    arc-gtk-theme \
    papirus-icon-theme \
    noto-fonts \
    noto-fonts-emoji \
    ttf-dejavu \
    ttf-font-awesome \
    rclone \
    nextcloud-client \
    keepassxc

# Choix de l'installation (AUR ou GitHub)
echo "Choisissez votre méthode d'installation pour Hyprland:"
echo "1) Installation depuis le dépôt AUR"
echo "2) Installation depuis le dépôt GitHub officiel"
read -p "Entrez 1 ou 2: " choice

# Supprimer les anciens dossiers avant de cloner les nouveaux
rm -rf ~/hyprland ~/Hyprland

if [ "$choice" -eq 1 ]; then
    # Installation depuis AUR

    # Clonage du dépôt AUR
    git clone https://aur.archlinux.org/hyprland-git.git ~/hyprland

    # Construction et installation du paquet AUR
    cd ~/hyprland
    makepkg -si --noconfirm

elif [ "$choice" -eq 2 ]; then
    # Installation depuis GitHub

    # Clonage du dépôt GitHub officiel
    git clone https://github.com/hyprwm/Hyprland.git ~/Hyprland

    # Compilation et installation
    cd ~/Hyprland
    make
    sudo make install
else
    echo "Choix invalide. Veuillez relancer le script et choisir 1 ou 2."
    exit 1
fi

# Configuration d'Hyprland et des applications associées
mkdir -p ~/.config/hypr ~/.config/waybar ~/.config/dunst ~/.config/rofi

cat <<EOF > ~/.config/hypr/hyprland.conf
# Configuration de base pour Hyprland
monitor=,preferred,auto,auto
\$terminal = kitty
\$fileManager = thunar
\$menu = rofi -show drun
exec-once = nm-applet &
exec-once = waybar & hyprpaper & firefox
exec-once = nextcloud &
exec-once = blueman-applet &
exec-once = keepassxc &
env = XCURSOR_SIZE,24
env = HYPRCURSOR_SIZE,24
env = GTK_THEME,Arc-Dark
env = QT_STYLE_OVERRIDE,kvantum
general {
    gaps_in = 5
    gaps_out = 20
    border_size = 2
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)
    resize_on_border = false 
    allow_tearing = false
    layout = dwindle
}
input {
    kb_layout = us
    follow_mouse = 1
    sensitivity = 0
    touchpad {
        natural_scroll = false
    }
}
\$mainMod = SUPER
bind = \$mainMod, Q, exec, \$terminal
bind = \$mainMod, E, exec, \$fileManager
bind = \$mainMod, F, exec, firefox
bind = \$mainMod, K, exec, keepassxc
bind = \$mainMod, N, exec, nextcloud
bind = \$mainMod, O, exec, openvpn
bind = \$mainMod, M, exec, rofi -show drun
EOF

cat <<EOF > ~/.config/waybar/config
{
    "layer": "top",
    "position": "top",
    "height": 30,
    "modules-left": ["network", "pulseaudio"],
    "modules-center": ["clock"],
    "modules-right": ["battery", "tray"],
    "network": {
        "interface": "wlan0",
        "format-connected": "{ifname}: {ipaddr}",
        "format-disconnected": "{ifname}: Disconnected"
    },
    "pulseaudio": {
        "format": "{volume}% {icon}",
        "format-muted": "Muted",
        "format-icons": ["", "", ""],
        "on-click": "pavucontrol"
    },
    "clock": {
        "format": "%a %b %d %H:%M"
    },
    "battery": {
        "format": "{capacity}% {icon}",
        "format-icons": ["", "", "", "", ""]
    },
    "tray": {
        "icon-theme": "Papirus"
    }
}
EOF

cat <<EOF > ~/.config/waybar/style.css
* {
    font-family: "DejaVu Sans", "Helvetica", "Arial", sans-serif;
    font-size: 12px;
    background-color: rgba(40, 44, 52, 0.8);
    color: #ffffff;
}
#waybar {
    height: 30px;
    padding: 0 10px;
    background-color: rgba(59, 66, 82, 0.8);
    border-bottom: 2px solid rgba(68, 68, 68, 0.5);
}
#waybar .module {
    padding: 0 10px;
}
#waybar .module:hover {
    background-color: rgba(76, 86, 106, 0.8);
}
#waybar .icon {
    font-family: "FontAwesome";
    font-size: 14px;
}
#tray > * {
    margin: 0 5px;
    background-color: transparent;
}
EOF

cat <<EOF > ~/.config/dunst/dunstrc
[global]
    font = DejaVu Sans 10
    format = "%s\n%b"
    sort = yes
    indicate_hidden = yes
    word_wrap = yes
    ignore_newline = no
    geometry = "300x5-30+30"
    transparency = 10
    separator_height = 2
    padding = 8
    frame_width = 1
    frame_color = "#444444"
    startup_notification = false
[urgency_low]
    timeout = 3
    background = "#222222"
    foreground = "#888888"
    frame_color = "#444444"
[urgency_normal]
    timeout = 10
    background = "#285577"
    foreground = "#ffffff"
    frame_color = "#4c7899"
[urgency_critical]
    timeout = 0
    background = "#900000"
    foreground = "#ffffff"
    frame_color = "#cc0000"
EOF

cat <<EOF > ~/.config/rofi/config.rasi
configuration {
    modi: "drun,run";
    theme: "Arc-Dark";
}
* {
    font: "DejaVu Sans 12";
}
window {
    background-color: rgba(46, 52, 64, 0.8);
    border-radius: 5px;
    padding: 10px;
    border-color: rgba(76, 86, 106, 0.5);
}
listview {
    background-color: rgba(59, 66, 82, 0.8);
    padding: 10px;
    fixed-height: 0;
    spacing: 5px;
}
element {
    background-color: rgba(67, 76, 94, 0.8);
    padding: 8px;
    border-radius: 5px;
}
element-icon {
    size: 20px;
}
element-text {
    padding-left: 5px;
    padding-right: 5px;
    color: #ECEFF4;
}
EOF

# Redémarrage de l'environnement graphique pour appliquer les changements
echo "Installation et configuration terminées. Vous pouvez redémarrer votre session pour appliquer les changements."
