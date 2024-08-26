OEF#!/bin/bash

# Mise à jour du système
sudo pacman -Syu --noconfirm

# Installation de yay (si non installé)
if ! command -v yay &> /dev/null; then
    echo "yay n'est pas installé. Installation de yay..."
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
fi

# Fonction pour installer un paquet avec gestion des conflits
install_package() {
    local package=$1

    echo "Installation de $package..."

    if yay -Qi $package &> /dev/null; then
        echo "$package est déjà installé."
        return 0
    fi

    # Essayer d'installer avec yay
    if yay -S --noconfirm --needed $package; then
        echo "$package installé avec succès avec yay."
        return 0
    fi

    echo "Échec de l'installation de $package avec yay. Recherche d'une autre source..."

    # Essayer d'installer avec pacman
    if sudo pacman -S --noconfirm --needed $package; then
        echo "$package installé avec succès avec pacman."
        return 0
    fi

    echo "Échec de l'installation de $package avec pacman. Recherche dans AUR..."

    # Essayer d'installer depuis AUR
    if yay -G $package && cd $package && makepkg -si --noconfirm; then
        echo "$package installé avec succès depuis AUR."
        cd ..
        rm -rf $package
        return 0
    fi

    echo "Échec de l'installation de $package depuis AUR. Recherche sur GitHub..."

    # Recherche sur GitHub
    if git clone "https://aur.archlinux.org/$package.git" && cd $package && makepkg -si --noconfirm; then
        echo "$package installé avec succès depuis GitHub."
        cd ..
        rm -rf $package
        return 0
    fi

    echo "Échec de l'installation de $package. Paquet non trouvé ou installation impossible."
    return 1
}

# Liste des paquets essentiels
essential_packages=(
    git base-devel cmake ninja make gcc wayland wayland-protocols wlroots
    qt5-wayland qt6-wayland cairo pango gdk-pixbuf2 xorg-xwayland
    xdg-desktop-portal-wlr polkit libinput kitty thunar firefox mousepad
    feh zathura file-roller pipewire pipewire-alsa pipewire-pulse
    pipewire-jack pavucontrol mpv networkmanager network-manager-applet
    openvpn networkmanager-openvpn ufw gufw rofi waybar dunst flameshot
    font-manager htop blueman bluez bluez-utils arc-gtk-theme
    papirus-icon-theme noto-fonts noto-fonts-emoji ttf-dejavu
    ttf-font-awesome rclone nextcloud-client keepassxc
)

# Installation des paquets essentiels
for package in "${essential_packages[@]}"; do
    install_package $package
done

# Installation des autres paquets un par un pour éviter les conflits
other_packages=(
    aquaman-git aquarius-git hyprcursor-git hyprpicker-git
    hyprwayland-scanner-git
)

for package in "${other_packages[@]}"; do
    install_package $package
done

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

# Ajout du fichier de configuration pour Waybar
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

# Ajout du fichier de configuration pour Dunst
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

# Ajout du fichier de configuration pour Rofi
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
    padding-right: 5px:
    color: #ECEFF4;
}
EOF

# Configuration de Hyprland
cat <<EOF > ~/.config/hypr/hyprland.conf

# Additional Configuration from .conf file

# #######################################################################################
# AUTOGENERATED HYPR CONFIG.
# PLEASE USE THE CONFIG PROVIDED IN THE GIT REPO /examples/hypr.conf AND EDIT IT,
# OR EDIT THIS ONE ACCORDING TO THE WIKI INSTRUCTIONS.
# #######################################################################################

#autogenerated = 1 # remove this line to remove the warning

# This is an example Hyprland config file.
# Refer to the wiki for more information.
# https://wiki.hyprland.org/Configuring/Configuring-Hyprland/

# Please note not all available settings / options are set here.
# For a full list, see the wiki

# You can split this configuration into multiple files
# Create your files separately and then link them to this file like this:
# source = ~/.config/hypr/myColors.conf

################
### MONITORS ###
################

# See https://wiki.hyprland.org/Configuring/Monitors/
monitor=,preferred,auto,auto

###################
### MY PROGRAMS ###
###################

# See https://wiki.hyprland.org/Configuring/Keywords/

# Set programs that you use
$terminal = kitty
$fileManager = thunar
$menu = wofi --show drun

#################
### AUTOSTART ###
#################

# Autostart necessary processes (like notifications daemons, status bars, etc.)
# Or execute your favorite apps at launch like this:

exec-once = nm-applet & blueman-applet &
exec-once = waybar & hyprpaper &
#exec-once = keepassxc & firefox & nextcloud &

#############################
### ENVIRONMENT VARIABLES ###
#############################

# See https://wiki.hyprland.org/Configuring/Environment-variables/

env = XCURSOR_SIZE,24
env = HYPRCURSOR_SIZE,24
env = GTK_THEME,Arc-Dark
env = QT_STYLE_OVERRIDE,kvantum

#####################
### LOOK AND FEEL ###
#####################

# Refer to https://wiki.hyprland.org/Configuring/Variables/

# https://wiki.hyprland.org/Configuring/Variables/#general
general { 
    gaps_in = 5
    gaps_out = 20

    border_size = 2

    # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)

    # Set to true enable resizing windows by clicking and dragging on borders and gaps
    resize_on_border = false 

    # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
    allow_tearing = false

    layout = dwindle
}

# https://wiki.hyprland.org/Configuring/Variables/#decoration
decoration {
    rounding = 10

    # Change transparency of focused and unfocused windows
    active_opacity = 1.0
    inactive_opacity = 1.0

    drop_shadow = true
    shadow_range = 4
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)

    # https://wiki.hyprland.org/Configuring/Variables/#blur
    blur {
        enabled = true
        size = 3
        passes = 1
        
        vibrancy = 0.1696
    }
}

# https://wiki.hyprland.org/Configuring/Variables/#animations
animations {
    enabled = true

    # Default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

    bezier = myBezier, 0.05, 0.9, 0.1, 1.05

    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = borderangle, 1, 8, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

# See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
dwindle {
    pseudotile = true # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
    preserve_split = true # You probably want this
}

# See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
master {
    new_status = master
}

# https://wiki.hyprland.org/Configuring/Variables/#misc
misc { 
    force_default_wallpaper = -1 # Set to 0 or 1 to disable the anime mascot wallpapers
    disable_hyprland_logo = false # If true disables the random hyprland logo / anime girl background. :(
}

#############
### INPUT ###
#############

# https://wiki.hyprland.org/Configuring/Variables/#input
input {
    kb_layout = us
    kb_variant =
    kb_model =
    kb_options =
    kb_rules =

    follow_mouse = 1

    sensitivity = 0 # -1.0 - 1.0, 0 means no modification.

    touchpad {
        natural_scroll = false
    }
}

# https://wiki.hyprland.org/Configuring/Variables/#gestures
gestures {
    workspace_swipe = false
}

# Example per-device config
# See https://wiki.hyprland.org/Configuring/Keywords/#per-device-input-configs for more
device {
    name = epic-mouse-v1
    sensitivity = -0.5
}

####################
### KEYBINDINGSS ###
####################

# See https://wiki.hyprland.org/Configuring/Keywords/
$mainMod = SUPER # Sets "Windows" key as main modifier

# Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
bind = $mainMod, Q, exec, $terminal
bind = $mainMod, C, killactive,
bind = $mainMod, M, exit,
bind = $mainMod, E, exec, $fileManager
bind = $mainMod, V, togglefloating,
bind = $mainMod, R, exec, $menu
bind = $mainMod, P, pseudo, # dwindle
bind = $mainMod, J, togglesplit, # dwindle
bind = $mainMod, Z, exec, rofi -show drun

# Move focus with mainMod + arrow keys
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# Switch workspaces with mainMod + [0-9]
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10

# Move active window to a workspace with mainMod + SHIFT + [0-9]
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9
bind = $mainMod SHIFT, 0, movetoworkspace, 10

# Example special workspace (scratchpad)
bind = $mainMod, S, togglespecialworkspace, magic
bind = $mainMod SHIFT, S, movetoworkspace, special:magic

# Scroll through existing workspaces with mainMod + scroll
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1

# Move/resize windows with mainMod + LMB/RMB and dragging
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow
EOF
# Redémarrage de l'environnement graphique pour appliquer les changements
echo "Installation et configuration terminées. Vous pouvez redémarrer votre session pour appliquer les changements."
