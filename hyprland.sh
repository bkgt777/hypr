#!/bin/bash

# Mise à jour du système
sudo pacman -Syu --noconfirm

# Installation des dépendances nécessaires
sudo pacman -S --noconfirm \
    git \
    base-devel \
    cmake \
    meson \
    ninja \
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
    kitty \
    dolphin \
    firefox \
    keepassxc \
    nextcloud-client \
    openvpn \
    network-manager-applet \
    bluez \
    bluez-utils \
    pulseaudio \
    pulseaudio-alsa \
    pulseaudio-bluetooth \
    pavucontrol \
    rofi \
    waybar \
    dunst \
    noto-fonts \
    noto-fonts-emoji \
    ttf-dejavu \
    ttf-font-awesome \
    jq

# Clonage et installation de Hyprland depuis le dépôt original qui a fonctionné précédemment
git clone https://github.com/hyprwm/Hyprland.git ~/Hyprland
cd ~/Hyprland || { echo "Cloning failed or directory does not exist."; exit 1; }

# Vérification de l'existence du PKGBUILD avant de procéder
if [ ! -f "PKGBUILD" ]; then
    echo "PKGBUILD does not exist. Exiting."
    exit 1
fi

# Construction et installation du paquet Hyprland
makepkg -si --noconfirm --needed --overwrite '*'

# Création des dossiers de configuration
mkdir -p ~/.config/hypr
mkdir -p ~/.config/waybar
mkdir -p ~/.config/dunst
mkdir -p ~/.config/rofi

# Création du fichier hyprland.conf
cat <<EOF > ~/.config/hypr/hyprland.conf
################
### MONITORS ###
################

monitor=,preferred,auto,auto

###################
### MY PROGRAMS ###
###################

\$terminal = kitty
\$fileManager = dolphin
\$menu = rofi -show drun

#################
### AUTOSTART ###
#################

exec-once = nm-applet &
exec-once = waybar & hyprpaper & firefox
exec-once = nextcloud &
exec-once = blueman-applet &
exec-once = keepassxc &

#############################
### ENVIRONMENT VARIABLES ###
#############################

env = XCURSOR_SIZE,24
env = HYPRCURSOR_SIZE,24
env = GTK_THEME,Adwaita:dark
env = QT_STYLE_OVERRIDE,kvantum

#####################
### LOOK AND FEEL ###
#####################

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

decoration {
    rounding = 10
    active_opacity = 0.85
    inactive_opacity = 0.75
    drop_shadow = true
    shadow_range = 4
    shadow_render_power = 3
    col.shadow = rgba(0, 0, 0, 0.5)
    blur {
        enabled = true
        size = 5
        passes = 2
        vibrancy = 0.2
    }
}

animations {
    enabled = true
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = borderangle, 1, 8, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

dwindle {
    pseudotile = true
    preserve_split = true
}

master {
    new_status = master
}

misc { 
    force_default_wallpaper = -1
    disable_hyprland_logo = false
}

#############
### INPUT ###
#############

input {
    kb_layout = us
    follow_mouse = 1
    sensitivity = 0
    touchpad {
        natural_scroll = false
    }
}

gestures {
    workspace_swipe = false
}

device {
    name = epic-mouse-v1
    sensitivity = -0.5
}

###################
### KEYBINDINGS ###
###################

\$mainMod = SUPER
bind = \$mainMod, Q, exec, \$terminal
bind = \$mainMod, E, exec, \$fileManager
bind = \$mainMod, F, exec, firefox
bind = \$mainMod, K, exec, keepassxc
bind = \$mainMod, N, exec, nextcloud
bind = \$mainMod, O, exec, openvpn
bind = \$mainMod, M, exec, rofi -show drun
EOF

# Configuration de Waybar avec des icônes, styles et transparence
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

# Configuration de Dunst pour les notifications avec thème transparent et police DejaVu
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

# Configuration de Rofi pour un menu avec des icônes, thème transparent, et police DejaVu
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
