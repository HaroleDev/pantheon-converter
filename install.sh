#!/bin/bash

# Ubuntu to elementary OS conversion script
# This is my first bash script I"ve written after looking through thousands of StackExchange/StackOverflow threads and articles about writing bash scripts.

echo "Welcome to the Ubuntu to elementary OS conversion script"
echo "This is a test script made by Harole (https://github.com/HaroleDev) to attempt converting from a fresh Ubuntu installation into elementary OS."

echo # New line
[ "$UID" -eq 0 ] || { echo "This script must be run as root."; exit 1;}

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    local DISTRIB=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
    if [[ ${DISTRIB} = "Ubuntu"* ]]; then
        if uname -a | grep -q '^Linux.*Microsoft'; then
            echo "Your distro is compatible, but not in a Windows Subsystem for Linux environment. Try again on a real hardware or in a VM."
        else
            # native ubuntu
        fi
        elif [[ ${DISTRIB} = "Debian"* ]]; then
        echo "Your distro is incompatible with this conversion script."
    else
        echo "Your distro is incompatible with this conversion script."
    fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Your OS is incompatible with this conversion script."
fi

while true; do
    
    read -p "Are you sure to proceed this process? (y/n) " yn
    
    case $yn in
        [yY] ) echo; break;;
        [nN] ) echo; exit;;
        * ) echo; exit 1;;
    esac
    
done

# Preparing for command
sudo apt install software-properties-common -y

# Adding sources
codename=$(cat /etc/os-release | grep UBUNTU_CODENAME | cut -d = -f 2 ||
cat /etc/os-release | grep UBUNTU_VERSION_CODENAME | cut -d = -f 2)

# Remove all sources
sudo rm -v /etc/apt/sources.list.d/*

## elementary.list sources
sudo touch /etc/apt/sources.list.d/elementary.list
sudo sh -c "cat > /etc/apt/sources.list.d/elementary.list << EOF
deb https://ppa.launchpadcontent.net/elementary-os/stable/ubuntu $codename main
deb-src https://ppa.launchpadcontent.net/elementary-os/stable/ubuntu $codename main
EOF"

## patches.list sources
sudo touch /etc/apt/sources.list.d/patches.list
sudo sh -c "cat > /etc/apt/sources.list.d/patches.list << EOF
deb https://ppa.launchpadcontent.net/elementary-os/os-patches/ubuntu $codename main
deb-src https://ppa.launchpadcontent.net/elementary-os/os-patches/ubuntu $codename main
EOF"

sudo add-apt-repository ppa:elementary-os/stable -y
sudo add-apt-repository ppa:elementary-os/os-patches -y

sudo apt update && apt upgrade -y

# Login manager
sudo apt install lightdm -y
sudo apt remove unity-* -y *-greeter gdm3
sudo apt install pantheon-greeter plymouth-theme-elementary -y

echo "/usr/sbin/lightdm" > /etc/X11/default-display-manager
DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true dpkg-reconfigure lightdm
echo set shared/default-x-display-manager lightdm | debconf-communicate

# Remove all desktops
## GNOME
sudo apt autoremove --purge ubuntu-desktop ubuntu-gnome-desktop ubuntu-wallpapers* ubuntu-standard ubuntu-release* ubuntu-report ubuntu-settings -y
sudo apt autoremove --purge gnome gnome-shell vanilla-gnome-desktop gnome-calculator gnome-control-center file-roller nautilus eog gnome-disk-utility gedit gnome-system-monitor gnome-logs gnome-keyring
## MATE
sudo apt autoremove --purge mate-desktop-environment mate-desktop-environment-extras ubuntu-mate* mate* -y
## XFCE
sudo apt-get autoremove --purge plymouth-theme-xubuntu-logo plymouth-theme-xubuntu-text screensaver-default-images scrollkeeper shimmer-themes system-tools-backends thunar* ttf-droid tumbler tumbler-common xbrlapi xchat xchat-common xfburn xfce* xfconf xfdesktop4* xfwm4 xscreensaver xscreensaver-data xscreensaver-gl xubuntu-artwork xubuntu-default-settings xubuntu-desktop xubuntu-docs xubuntu-icon-theme xubuntu-wallpapers -y
## Cinnamon
sudo apt autoremove --purge cinnamon-desktop-environment cinnamon* -y
## KDE
sudo apt autoremove --purge kde-standard kde-full kde-plasma* -y

# Desktop
sudo apt install elementary-desktop elementary-minimal elementary-standard -y
# Power
sudo apt install acpi -y
# Miscellaneous
sudo apt install org.gnome.fileroller ibus -y

# Removing leftovers
sudo apt remove update-manager snapd firefox -y

# Clean up
sudo apt autoremove -y && sudo apt autoclean -y

# Log out
sudo reboot now