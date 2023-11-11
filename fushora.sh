set -e

scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")

printf " ${YELLOW} Current Location : ${scriptDir} \n"

GREEN="$(tput setaf 2)[OK]$(tput sgr0)"
RED="$(tput setaf 1)[ERROR]$(tput sgr0)"
YELLOW="$(tput setaf 3)[NOTE]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
LOG="install.log"

read -n1 -rep "${CAT} Install RPM, Flatpaks and Brew packages ? (y/n)" inst
echo

if [[ $inst =~ ^[Nn]$ ]]; then
    printf "${YELLOW} Canceled \n"
            exit 1
        fi

if [[ $inst =~ ^[Yy]$ ]]; then

   printf " ------------- DNF / RPM ------------- \n"

   printf " Adding repositories \n"

   sudo dnf -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm 
   sudo dnf copr enable che/nerd-fonts -y
   sudo dnf copr enable solopasha/hyprland -y
   sudo dnf copr enable ffreiheit/starship -y

   printf "Installing RPM packages \n"

   apps="flatpak git steam-devices wayland* nerd-fonts btop dolphin lutris zsh"
   deps="qt5-qtwayland qt6-qtwayland qt5ct qt6ct qt5-qtsvg qt5-qtquickcontrols2 qt5-qtgraphicaleffects gtk3 polkit-gnome wireplumber jq wl-clipboard"
   dotnet="dotnet-sdk-7.0 aspnetcore-runtime-7.0 dotnet-runtime-7.0"
   hyprland="hyprland sddm kitty mako waybar-git wofi wlogout xdg-desktop-portal-hyprland swappy grim slurp pamixer pavucontrol brightnessctl bluez blueman network-manager-applet gvfs file-roller starship papirus-icon-theme google-noto-emoji-fonts lxappearance xfce4-settings"
   flatpaks="com.brave.Browser com.discordapp.Discord com.github.tchx84.Flatseal com.gitlab.davem.ClamTk com.mastermindzh.tidal-hifi com.valvesoftware.Steam org.gimp.GIMP org.inkscape.Inkscape org.onlyoffice.desktopeditors org.videolan.VLC tv.plex.PlexDesktop com.obsproject.Studio io.github.achetagames.epic_asset_manager com.mojang.Minecraft com.slack.Slack im.riot.Riot net.davidotek.pupgui2 com.jetbrains.Rider com.jetbrains.WebStorm"

    if ! sudo dnf install -y $deps $dotnet $apps $hyprland 2>&1 | tee -a $LOG; then
        printf "${RED} Something went wrong - please check the install.log \n"
        exit 1
    fi
    printf "${GREEN} All necessary packages installed successfully."

    printf " ------------- FLATPAK -------------\n"

    printf " Ading repositories (system and user) \n"

    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    printf " Installing Flatpaks packages to User \n"

    if ! flatpak install -u $flatpaks -y 2>&1 | tee -a $LOG; then
        printf "${RED} Something went wrong - please check the install.log \n"
    fi

    printf " ------------- BREW -------------\n"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    (echo; echo 'eval "$(homebrew/bin/brew shellenv)"') >> /home/$USER/.bashrc
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
else
    printf "${RED} Packages not installed - please check the install.log"
    sleep 1
fi

printf " ${YELLOW} Creating default dirs \n"
mkdir -p ~/.config
mkdir -p ~/Documents
mkdir -p ~/Softwares
mkdir -p ~/Pictures
mkdir -p ~/Videos
mkdir -p ~/Music
mkdir -p ~/Downloads

printf " ${YELLOW} Enabling SDDM \n"
systemctl set-default graphical.target

printf " ${YELLOW} Copying Hyprland Configuration \n"
mkdir -p ~/.config/hypr
cp $scriptDir/hyprland.conf ~/.config/hypr/

read -n1 -rep "${CAT} Reboot now ? (y/n)" inst

if [[ $inst =~ ^[Nn]$ ]]; then
    printf "${YELLOW} Reboot Canceled \n"
            exit 1
        fi

if [[ $inst =~ ^[Yy]$ ]]; then

reboot

fi
