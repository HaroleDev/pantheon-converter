#!/bin/bash

# Ubuntu to elementary OS conversion script
# This is my first bash script I"ve written after looking through thousands of StackExchange/StackOverflow threads and articles about writing bash scripts.

echo "Welcome to the Ubuntu to elementary OS conversion script"
echo "This is a script made by Harole (https://github.com/HaroleDev) to attempt converting from a fresh Ubuntu installation into elementary OS."

echo # New line
[ "$UID" -eq 0 ] || { echo "This script must be run as root."; exit 1;}

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    DISTRIB=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
    if [[ ${DISTRIB} = "Ubuntu"* ]]; then
        if uname -a | grep -q '^Linux.*Microsoft'; then
            echo "Your distro is compatible, but not in a Windows Subsystem for Linux environment. Try again on a real hardware or in a VM."
            exit 1
        else
            echo
        fi
        elif [[ ${DISTRIB} = "Debian"* ]]; then
        echo "Your distro is incompatible with this conversion script."
        exit 1
    fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Your OS is incompatible with this conversion script."
    exit 1
else
    echo "Your distro is incompatible with this conversion script."
    exit 1
fi

while true; do
    read -p "Are you sure to proceed this process? (y/n) " yn
    case $yn in
        [yY] ) echo; break;;
        [nN] ) echo "Process declined."; exit;;
        * ) echo; exit 1;;
    esac
done

set -e

# Remove all sources
sudo rm -v /etc/apt/sources.list.d/* || mkdir /etc/apt/sources.list.d/ || echo "Sources already cleansed."

# Preparing for command
sudo apt install software-properties-common lsb-release -y

# Adding sources
sudo add-apt-repository ppa:elementary-os/stable -y
sudo add-apt-repository ppa:elementary-os/os-patches -y

## Set variable for the distro's codename
CODENAME=$(lsb_release --release | cut -f2)

## elementary.list sources
sudo touch /etc/apt/sources.list.d/elementary.list
sudo sh -c "cat > /etc/apt/sources.list.d/elementary.list << EOF
deb https://ppa.launchpadcontent.net/elementary-os/stable/ubuntu $CODENAME main
deb-src https://ppa.launchpadcontent.net/elementary-os/stable/ubuntu $CODENAME main
EOF"

## patches.list sources
sudo touch /etc/apt/sources.list.d/patches.list
sudo sh -c "cat > /etc/apt/sources.list.d/patches.list << EOF
deb https://ppa.launchpadcontent.net/elementary-os/os-patches/ubuntu $CODENAME main
deb-src https://ppa.launchpadcontent.net/elementary-os/os-patches/ubuntu $CODENAME main
EOF"

# Update and Upgrade packages to the latest version
sudo apt update && apt upgrade -y

# Login manager
sudo apt install lightdm -y
sudo apt remove unity-* *-greeter gdm3 -y
sudo apt install pantheon-greeter plymouth-theme-elementary -y

echo "/usr/sbin/lightdm" > /etc/X11/default-display-manager
DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true dpkg-reconfigure lightdm
echo set shared/default-x-display-manager lightdm | debconf-communicate

# Desktop
sudo apt install elementary-desktop elementary-minimal elementary-standard -y
# Power
sudo apt install acpi power-profiles-daemon -y
# Miscellaneous
sudo apt install org.gnome.fileroller ibus -y
sudo apt install 

# Removing leftovers
sudo snap remove --purge firefox
sudo snap remove --purge snap-store
sudo snap remove --purge gnome-3-38-2004
sudo snap remove --purge gtk-common-themes
sudo snap remove --purge snapd-desktop-integration
sudo snap remove --purge bare
sudo snap remove --purge core20
sudo snap remove --purge snapd
sudo rm -rf -v /var/cache/snapd/
sudo apt autoremove --purge update-manager snapd firefox -y
sudo rm -rf ~/snap

sudo apt remove system-config-printer -y

# Remove promotions from Ubuntu (https://github.com/Skyedra/UnspamifyUbuntu)
sudo pro config set apt_news=false
sudo sed -Ezi.orig \ -e 's/(def _output_esm_service_status.outstream, have_esm_service, service_type.:\n)/\1    return\n/' \ -e 's/(def _output_esm_package_alert.*?\n.*?\n.:\n)/\1    return\n/' \ /usr/lib/update-notifier/apt_check.py
sudo /usr/lib/update-notifier/update-motd-updates-available --force
sudo sed -i 's/^ENABLED=.*/ENABLED=0/' /etc/default/motd-news
sudo rm /var/lib/ubuntu-advantage/messages/motd-esm-announce

# Remove all desktops
## GNOME
sudo apt autoremove --purge ubuntu-desktop ubuntu-gnome-desktop ubuntu-wallpapers* ubuntu-standard ubuntu-release* ubuntu-report ubuntu-settings ubuntu-*-sounds* -y
sudo apt autoremove --purge gnome gnome-shell gnome-characters vanilla-gnome-desktop gnome-calculator gnome-control-center file-roller nautilus eog gnome-disk-utility gedit gnome-system-monitor gnome-logs gnome-keyring -y
## MATE
sudo apt autoremove --purge mate-desktop-environment mate-desktop-environment-extras ubuntu-mate* mate* -y
## XFCE
sudo apt-get autoremove --purge plymouth-theme-xubuntu-logo plymouth-theme-xubuntu-text shimmer-themes system-tools-backends thunar* ttf-droid tumbler tumbler-common xbrlapi xchat* xfburn xfce* xfconf xfdesktop4* xfwm4 xscreensaver xscreensaver-data xscreensaver-gl xubuntu-artwork xubuntu-default-settings xubuntu-desktop xubuntu-docs xubuntu-icon-theme xubuntu-wallpapers -y
## Cinnamon
sudo apt autoremove --purge cinnamon-desktop-environment cinnamon* -y
## KDE
sudo apt autoremove --purge kde-standard kde-full kde-plasma* -y

# Clean up
sudo apt autoremove -y && sudo apt autoclean -y

# Update and Upgrade packages once again
sudo apt update && apt upgrade -y

# Log out
sudo reboot now