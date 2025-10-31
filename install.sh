#!/bin/bash

sudo -v

sudo xbps-install -Sy void-repo-nonfree

sudo xbps-install -Syu

sudo xbps-install -Sy xorg xinit cronie dbus elogind NetworkManager vulkan-loader mesa-vulkan-radeon mesa-vaapi mesa-vdpau nvidia bluez pipewire wireplumber libspa-bluetooth libjack-pipewire alsa-pipewire picom i3 alacritty chromium polybar feh 

sudo ln -s /etc/sv/dbus /var/service
sudo ln -s /etc/sv/elogind /var/service
sudo ln -s /etc/sv/cronie /var/service
sudo ln -s /etc/sv/NetworkManager /var/service
sudo ln -s /etc/sv/bluetoothd /var/service

sudo mkdir -p ~/.config/pipewire/pipewire.conf.d
sudo ln -s /usr/share/examples/wireplumber/10-wireplumber.conf ~/.config/pipewire/pipewire.conf.d/
sudo ln -s /usr/share/examples/pipewire/20-pipewire-pulse.conf ~/.config/pipewire/pipewire.conf.d/

sudo mkdir -p /etc/alsa/conf.d
sudo ln -s /usr/share/alsa/alsa.conf.d/50-pipewire.conf /etc/alsa/conf.d
sudo ln -s /usr/share/alsa/alsa.conf.d/99-pipewire-default.conf /etc/alsa/conf.d

echo "/usr/lib/pipewire-0.3/jack" | sudo tee /etc/ld.so.conf.d/pipewire-jack.conf
sudo ldconfig

sudo rm /var/service/wpa_supplicant