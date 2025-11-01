#!/bin/bash
# Post-install setup script for Void Linux
# Automates system configuration, package installation, and service setup

set -e  # Exit immediately if a command fails

echo ">>> Requesting sudo privileges..."
sudo -v

# Keep sudo alive until the script finishes
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &

echo ">>> Enabling nonfree repository..."
sudo xbps-install -Sy void-repo-nonfree

echo ">>> Updating system..."
sudo xbps-install -Syu

echo ">>> Installing packages..."
sudo xbps-install -Sy \
  xorg xinit cronie dbus elogind NetworkManager \
  vulkan-loader mesa-vulkan-radeon mesa-vaapi mesa-vdpau nvidia \
  bluez pipewire libspa-bluetooth alsa-pipewire libjack-pipewire \
  picom i3 alacritty chromium polybar feh lf nvim rofi

echo ">>> Enabling essential services..."
for svc in dbus elogind cronie bluetoothd; do
  sudo ln -sf /etc/sv/$svc /var/service/
done

echo ">>> Configuring PipeWire and ALSA..."
mkdir -p ~/.config/pipewire/pipewire.conf.d
sudo ln -sf /usr/share/examples/wireplumber/10-wireplumber.conf ~/.config/pipewire/pipewire.conf.d/
sudo ln -sf /usr/share/examples/pipewire/20-pipewire-pulse.conf ~/.config/pipewire/pipewire.conf.d/

sudo mkdir -p /etc/alsa/conf.d
sudo ln -sf /usr/share/alsa/alsa.conf.d/50-pipewire.conf /etc/alsa/conf.d/
sudo ln -sf /usr/share/alsa/alsa.conf.d/99-pipewire-default.conf /etc/alsa/conf.d/

echo ">>> Setting up PipeWire JACK support..."
echo "/usr/lib/pipewire-0.3/jack" | sudo tee /etc/ld.so.conf.d/pipewire-jack.conf
sudo ldconfig

echo ">>> Disabling other network managers (wpa_supplicant, dhcpcd, wicd)..."
for svc in wpa_supplicant dhcpcd wicd; do
    if [ -L /var/service/$svc ]; then
        echo ">>> Stopping $svc..."
        sudo sv down $svc || true
        sudo rm -f /var/service/$svc
    fi
done
sudo ln -sf /etc/sv/NetworkManager /var/service

echo ">>> Setup complete! You may want to reboot to apply all changes."
