#!/bin/bash

# Update the system clock
timedatectl set-ntp true

# Partition the disk
fdisk /dev/nvme0n1 <<EEOF
o
n
p
1

+512M
n
p
2

+30G
n
p
3


w
EEOF

# Format the partitions
mkfs.ext4 /dev/nvme0n1p1
mkfs.ext4 /dev/nvme0n1p2
mkfs.ext4 /dev/nvme0n1p3

# Mount the file systems
mount /dev/nvme0n1p2 /mnt
mkdir /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
mkdir /mnt/home
mount /dev/nvme0n1p3 /mnt/home

# Install base packages with LTS kernel
pacstrap /mnt base linux-lts linux-lts-headers linux-firmware

# Generate fstab
arch-chroot /mnt

genfstab -U /mnt >> /mnt/etc/fstab

# Time zone and locale
ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
hwclock --systohc

# Localization
echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
locale-gen

# Network configuration
echo 'BigPenguin' > /etc/hostname

# Initramfs
mkinitcpio -P

# Root password
passwd

# Boot loader
pacman -S grub
grub-install --target=i386-pc /dev/nvme0n1
grub-mkconfig -o /boot/grub/grub.cfg

# Additional software and settings
pacman -S plasma-desktop sddm firefox keepassxc librewolf-bin zoom strawberry nicotine+ mpv yt-dlp ckb-next libreoffice nvidia steam discord slack openssh ufw zsh oh-my-zsh-git neofetch jellyfin noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra

# Enable services
systemctl enable sddm
systemctl enable sshd
systemctl enable ufw

# Firewall
ufw enable

# Papirus Dark Icons
pacman -S papirus-icon-theme

# Set up Zsh and oh-my-zsh
chsh -s /usr/bin/zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="jonathan"/' ~/.zshrc

# Reboot
reboot