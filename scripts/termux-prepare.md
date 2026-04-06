# Prepare Termux

## Termux Setup

```sh
# info
passwd
whoami
ifconfig
# packages
termux-change-repo
pkg in -y openssh git
# services
sshd
# setup repo
mkdir -p ~/p
git -C ~/p clone https://github.com/xingqingxyz/wish.git
cd ~/p/wish
./scripts/termux-bootsctrap.sh
```

## Connect to Termux via SSH forwarded by ADB

```ps1
# adb
adb connect 192.168.0.101:5555
adb forward tcp:8022 tcp:8022
ssh-keygen -t ed25519
ssh user@localhost:8022
ssh-copy-id -i ~/.ssh/id_ed25519.pub termux1
scp ~/.ssh/id_ed25519 termux1:
ssh termux1
# summary
adb connect 192.168.0.101:5555 && adb forward tcp:8022 tcp:8022 && ssh termux1
```
