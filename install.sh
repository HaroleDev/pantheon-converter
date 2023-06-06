#! /bin/bash

# Ubuntu to elementary OS conversion script
# This is my first bash script I"ve written after looking through thousands of StackExchange/StackOverflow threads and articles about writing bash scripts.

echo "Welcome to the Ubuntu to elementary OS conversion script"
echo "This is a test script made by Harole (https://github.com/HaroleDev) to attempt converting from a fresh Ubuntu installation into elementary OS."

[ "$UID" -eq 0 ] || { echo "This script must be run as root."; exit 1;}

# Remove all desktops
## Ubuntu
sudo apt autoremove --purge ubuntu-desktop ubuntu-wallpapers* -y
## MATE
sudo apt autoremove --purge mate-desktop-environment mate-desktop-environment-extras ubuntu-mate-themes -y
## Cinnamon
sudo apt autoremove --purge cinnamon-desktop-environment cinnamon* -y
## KDE
sudo apt autoremove --purge kde-standard -y

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
sudo apt install lightdm pantheon-greeter -y

echo "/usr/sbin/lightdm" > /etc/X11/default-display-manager
DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true dpkg-reconfigure lightdm
echo set shared/default-x-display-manager lightdm | debconf-communicate

# Desktop
sudo apt install elementary-desktop elementary-minimal elementary-standard -y
# Power
sudo apt install acpi -y
# Miscellaneous
sudo apt install file-roller ibus -y
sudo apt remove unity-*

# Clean up
sudo apt autoremove -y && sudo apt autoclean

# Reboot
sudo reboot now