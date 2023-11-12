scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")

printf " Running in ${scriptDir} \n"

printf " Copying hyprland config \n"
cp -r $scriptDir/Configs/* ~/.config/
