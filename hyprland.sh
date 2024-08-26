#!/bin/bash

# Mise à jour du système
sudo pacman -Syu --noconfirm

# Installation des outils de base pour le système et le développement
sudo pacman -S --noconfirm \
    git \
    base-devel \  # Outils de développement de base nécessaires pour la compilation
    cmake \       # Utilisé pour générer les fichiers de build
    ninja \       # Outil de build performant
    make \        # Outil de compilation
    gcc           # Compilateur C/C++

# Installation des composants Wayland et des bibliothèques nécessaires pour Hyprland
sudo pacman -S --noconfirm \
    wayland \                      # Système de fenêtres moderne
    wayland-protocols \            # Protocoles pour Wayland
    wlroots \                      # Bibliothèque utilisée par Hyprland
    qt5-wayland \                  # Support Wayland pour les applications Qt5
    qt6-wayland \                  # Support Wayland pour les applications Qt6
    cairo \                        # Bibliothèque graphique
    pango \                        # Bibliothèque pour le rendu du texte
    gdk-pixbuf2 \                  # Bibliothèque pour la gestion des images
    xorg-xwayland \                # Compatibilité X11 pour Wayland
    xdg-desktop-portal-wlr \       # Intégration des portails avec Wayland
    polkit \                       # Gestion des permissions système
    libinput                       # Gestion des périphériques d'entrée (souris, clavier)

# Installation des applications de base pour l'environnement de bureau
sudo pacman -S --noconfirm \
    kitty \                        # Terminal léger et performant
    thunar \                       # Gestionnaire de fichiers léger
    firefox \                      # Navigateur web robuste
    mousepad \                     # Éditeur de texte simple et léger
    feh \                          # Visionneuse d'images légère (aussi pour le fond d'écran)
    zathura \                      # Visionneuse de PDF légère
    file-roller                    # Gestionnaire de fichiers compressés

# Installation des outils multimédia
sudo pacman -S --noconfirm \
    pipewire \                     # Remplacement moderne de PulseAudio
    pipewire-alsa \                # Support ALSA pour PipeWire
    pipewire-pulse \               # Émulation de PulseAudio avec PipeWire
    pipewire-jack \                # Émulation de Jack avec PipeWire
    pavucontrol \                  # Contrôle du volume pour PipeWire/PulseAudio
    mpv                            # Lecteur multimédia léger et polyvalent

# Installation des outils réseau et de sécurité
sudo pacman -S --noconfirm \
    networkmanager \               # Gestionnaire de réseau
    network-manager-applet \       # Applet pour gérer les connexions réseau
    openvpn \                      # Client VPN
    networkmanager-openvpn \       # Intégration OpenVPN pour NetworkManager
    ufw \                          # Pare-feu simple à utiliser
    gufw                          # Interface graphique pour gérer UFW

# Installation des utilitaires de bureau
sudo pacman -S --noconfirm \
    rofi \                         # Menu d'application léger
    waybar \                       # Barre de statut configurable pour Wayland
    dunst \                        # Système de notifications léger
    flameshot \                    # Outil de capture d'écran riche en fonctionnalités
    font-manager \                 # Gestionnaire graphique de polices
    htop                           # Gestionnaire de tâches pour surveiller les ressources système

# Installation des outils Bluetooth
sudo pacman -S --noconfirm \
    blueman \                      # Gestionnaire Bluetooth avec interface graphique
    bluez \                        # Bluetooth stack
    bluez-utils                    # Utilitaires Bluetooth

# Installation des thèmes, icônes et polices pour l'apparence
sudo pacman -S --noconfirm \
    arc-gtk-theme \                # Thème GTK moderne
    papirus-icon-theme \           # Jeu d'icônes complet et esthétique
    noto-fonts \                   # Polices Noto
    noto-fonts-emoji \             # Support des emojis
    ttf-dejavu \                   # Polices DejaVu
    ttf-font-awesome               # Polices Font Awesome pour les icônes

# Installation des outils de productivité supplémentaires
sudo pacman -S --noconfirm \
    rclone \                       # Synchronisation de fichiers avec services cloud
    nextcloud-client \             # Client pour synchroniser avec Nextcloud
    keepassxc                      # Gestionnaire de mots de passe

# Clone the AUR repository for hyprland-git
git clone https://aur.archlinux.org/hyprland-git.git ~/hyprland-git

# Navigate to the repository directory
cd ~/hyprland-git

# Build and install the package
makepkg -si



# Création des dossiers de configuration pour Hyprland et les applications
mkdir -p ~/.config/hypr ~/.config/waybar ~/.config/dunst ~/.config/rofi

# Création du fichier de configuration de Hyprland
cat <<EOF > ~/.config/hypr/hyprland.conf
# Configuration de base pour Hyprland

# MONITORS: Configuration des écrans
monitor=,preferred,auto,auto

# PROGRAMMES: Définition des applications par défaut
\$terminal = kitty
\$fileManager = thunar
\$menu = rofi -show drun

# AUTOSTART: Applications à lancer au démarrage
exec-once = nm-applet &
exec-once = waybar & hyprpaper & firefox
exec-once = nextcloud &
exec-once = blueman-applet &
exec-once = keepassxc &

# ENVIRONMENT VARIABLES: Variables d'environnement
env = XCURSOR_SIZE,24
env = HYPRCURSOR_SIZE,24
env = GTK_THEME,Arc-Dark
env = QT_STYLE_OVERRIDE,kvantum

# LOOK AND FEEL: Apparence générale
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

# INPUT: Configuration des périphériques d'entrée
input {
    kb_layout = us
    follow_mouse = 1
    sensitivity = 0
    touchpad {
        natural_scroll = false
    }
}

# KEYBINDINGS: Raccourcis clavier
\$mainMod = SUPER
bind = \$mainMod, Q, exec, \$terminal
bind = \$mainMod, E, exec, \$fileManager
bind = \$mainMod, F, exec, firefox
bind = \$mainMod, K, exec, keepassxc
bind = \$mainMod, N, exec, nextcloud
bind = \$mainMod, O, exec, openvpn
bind = \$mainMod, M, exec, rofi -show drun
EOF

# Configuration de Waybar
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

# Configuration des styles de Waybar
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

# Configuration de Dunst (notifications)
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

# Configuration de Rofi (menu d'application)
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
