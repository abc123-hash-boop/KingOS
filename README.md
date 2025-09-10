# KingOS
My own Linux Distro, a ubuntu-based distro. Still working on it.
## How to get rootfs
Choose a version. Ubuntu 24.04 LTS is 
```bash
#get 24.04 LTS
wget https://cloud-images.ubuntu.com/releases/noble/release/ubuntu-24.04-server-cloudimg-amd64.squashfs
#get 25.04
https://cloud-images.ubuntu.com/releases/plucky/release/ubuntu-25.04-server-cloudimg-amd64.squashfs
```
Then unpack.
```bash
unsquashfs -d rootfs ubuntu-*-server-cloudimg-amd64.squashfs
```
Make sure you can see the ``` rootfs ``` folder.
### Why choose cloud image?
Because it is a full ubuntu base system, you can skip many steps, just like install basic tools(like curl, wget), and faster than ``` debootstrap ``` .
## Branding
Make your own branding by change ``` rootfs/etc/os-release ``` and ``` rootfs/etc/lsb-release ``` .
Change by your self.
Note:
Backup the original file. If ``` apt update ``` can not be use, recover the file.
Change ```rootfs/etc/issue ``` and ``` rootfs/etc/issue.net ```
If you want to custom hostname, change ``` rootfs/etc/hostname ``` .
## Chroot
```bash
bash chroot.sh
```
## Install/Remove feature
Lets update software.
Note: You don't need to modify source.list, because it is complete.
```chroot
apt update
apt upgrade -y
```
So, as a desktop system, you can remove ``` cloud-init ``` , because it is useless.
```bash
apt purge -y cloud-init
```
Then, install networking, with dhcp.
```bash
apt install -y network-manager
vim /etc/netplan/01-network.yaml
```
Then, write down this in vim:
```yaml
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    all-interfaces:
      dhcp4: true
      dhcp6: false
```
Then, apply
```bash
chown root:root /etc/netplan/01-network.yaml
chmod 600 /etc/netplan/01-network.yaml
netplan generate
```
You don't need wait-online, disable and mask it, plasma will do that.
```bash
sudo systemctl disable NetworkManager-wait-online.service
sudo systemctl mask NetworkManager-wait-online.service
```
Install Desktop, kde-plasma is tiny and easy to use. This might take a while, wait a minute.
```bash
apt install -y kde-plasma-desktop
```
Install casper and kernel
```
OLDER_KERNEL_ABI="6.14.0-27-generic"
apt-get install -y --allow-downgrades \
    casper \
    discover \
    laptop-detect \
    os-prober \
    keyutils \
    thermald \
    linux-image-${OLDER_KERNEL_ABI} \
    linux-headers-${OLDER_KERNEL_ABI} \
    linux-modules-extra-${OLDER_KERNEL_ABI} \
    --no-install-recommends
```
Remove ubuntu services
```bash
rm /etc/update-manager/ -rf
rm /etc/update-motd.d/ -rf
rm /etc/apt/apt.conf.d/20apt-esm-hook.conf -rf
```
config locales
```bash
dpkg-reconfigure locales
```
Select:
en_US.UTF-8 UTF-8
zh_CN.UTF-8 UTF-8

Default locale for the system environment choose en-US if you want english, or you can choose chinese
If you want chinese, don't forget run ``` apt install language-pack-zh-hans ``` .
Install system installer
```bash
apt install -y ubiquity
```
Display Driver for Intel UHD and AMD Vega
```bash
sudo apt update

# Intel GPU Driver + Xorg
sudo apt install -y xserver-xorg-video-intel

# Mesa （OpenGL、DRI）
sudo apt install -y mesa-utils libgl1-mesa-dri libglu1-mesa

# Vulkan （Intel）
sudo apt install -y mesa-vulkan-drivers vulkan-tools

# OpenGL / EGL
sudo apt install -y libgl1-mesa-dev libegl1-mesa-dev libgles2-mesa-dev

# Wayland 
sudo apt install -y libwayland-client0 libwayland-server0 libwayland-egl1-mesa

# AMD （OpenGL + DRI）
sudo apt install -y mesa-utils libgl1-mesa-dri libglu1-mesa

# Vulkan （AMD GPU）
sudo apt install -y mesa-vulkan-drivers vulkan-tools
```
Remove plymouth, because it is not useful and not stable.
```bash
apt purge plymouth
```
Web browser
You can install Chrome or firefox, Chrome is the best choice, because no ads.
I choose chrome.
```bash
curl -fsSL https://dl.google.com/linux/linux_signing_key.pub \
    | gpg --dearmor -o /etc/apt/keyrings/google-linux.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-linux.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
    > /etc/apt/sources.list.d/google-chrome.list
apt update
apt install -y google-chrome-stable
```
Some gaming...
If you want gaming, you can pre-install libraries, like ``` jdk ``` , Minecraft is my favorite game, if you play minecraft, ``` jdk ``` is useful.
```bash
apt install openjdk-21-jdk
```
Remove report
```bash
sudo apt purge ubuntu-report apport whoopsie
sudo apt autoremove -y --purge
```
For developers
Let's install build tools first
```bash
sudo apt install -y build-essential
```
Then, let's install vscode.
```bash
# Download and install Microsoft GPG Key
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg

# Add VS Code source
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
    > /etc/apt/sources.list.d/vscode.list

# Update and install VS Code
apt update
apt install -y code
```
## Configure Live user
```bash
cat << EOF > /etc/casper.conf
# This file should go in /etc/casper.conf
# Supported variables are:
# USERNAME, USERFULLNAME, HOST, BUILD_SYSTEM, FLAVOUR

export USERNAME="live"
export USERFULLNAME="Live session user"
export HOST="KingOS"
export BUILD_SYSTEM="Ubuntu"

# USERNAME and HOSTNAME as specified above won't be honoured and will be set to
# flavour string acquired at boot time, unless you set FLAVOUR to any
# non-empty string.

export FLAVOUR="KingOS"
EOF
```
## Clean up
```bash
rm -rf /tmp/* ~/.bash_history
rm -rf /bin.usr-is-merged
rm -rf /lib.usr-is-merged
rm -rf /sbin.usr-is-merged
apt clean -y
rm -rf /var/cache/apt/archives/*
rm -rf /var/log/*
truncate -s 0 /etc/machine-id
truncate -s 0 /var/lib/dbus/machine-id
```
## Quit chroot
```bash
exit
```
## Pack iso
Exporting
```bash
mkdir -p image/{casper,isolinux,.disk}
sudo cp rootfs/boot/vmlinuz-**-**-generic image/casper/vmlinuz
sudo cp rootfs/boot/initrd.img-**-**-generic image/casper/initrd
sudo chroot rootfs dpkg-query -W --showformat='${Package} ${Version}\n' | sudo tee image/casper/filesystem.manifest >/dev/null 2>&1
    sudo mksquashfs rootfs image/casper/filesystem.squashfs \
        -noappend -no-duplicates -no-recovery \
        -wildcards -b 1M \
        -comp zstd -Xcompression-level 19 \
        -e "var/cache/apt/archives/*" \
        -e "root/*" \
        -e "root/.*" \
        -e "tmp/*" \
        -e "tmp/.*" \
        -e "swapfile"
```
# Replace these files in ubuntu installer iso, then, it is done
## News: KingOS 1.0 LTS is now built, will test in today or tomorrow, then release
