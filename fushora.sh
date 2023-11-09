set -e

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

   printf " ------------- DNF / RPM ------------ \n"

   printf " Adding repositories \n"

   sudo dnf -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm 
   sudo dnf copr enable che/nerd-fonts -y
   sudo dnf copr enable solopasha/hyprland -y
   printf "Installing RPM packages \n"

   apps="flatpak git steam-devices wayland* nerd-fonts btop"
   deps="qt5-qtwayland qt6-qtwayland qt5ct qt6ct qt5-qtsvg qt5-qtquickcontrols2 qt5-qtgraphicaleffects gtk3 polkit-gnome wireplumber jq wl-clipboard"
   hyprland="hyprland sddm kitty mako "
   flatpaks="com.brave.Browser com.discordapp.Discord com.github.tchx84.Flatseal com.gitlab.davem.ClamTk com.mastermindzh.tidal-hifi com.valvesoftware.Steam org.gimp.GIMP org.inkscape.Inkscape org.onlyoffice.desktopeditors org.videolan.VLC tv.plex.PlexDesktop com.obsproject.Studio org.gnome.Boxes"

    if ! sudo dnf install -y $deps $dnf $hyprland $font_pkgs $font_pkgs 2>&1 | tee -a $LOG; then
        print_error " Something went wrong - please check the install.log \n"
        exit 1
    fi
    printf "${GREEN} All necessary packages installed successfully."

    printf " ------------- FLATPAK --------------\n"

    printf " Ading repositories (system and user) \n"

    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo

   printf " Installing Flatpaks packages to User \n"

   flatpak install -u $flatpaks -y

else
    echo
    print_error " Packages not installed - please check the install.log"
    sleep 1
fi
