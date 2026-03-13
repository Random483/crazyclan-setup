#!/usr/bin/env bash
# -------------------------------------------------------------------
# 41-unity-hub.sh (renamed from 45)
# Installs Unity Hub on Ubuntu/Pop!_OS systems
# -------------------------------------------------------------------
set -euo pipefail

apt update -y
apt install -y curl
install -d /etc/apt/keyrings
curl -fsSL https://hub.unity3d.com/linux/keys/public | gpg --dearmor -o /etc/apt/keyrings/unityhub.gpg
if [ ! -f /etc/apt/sources.list.d/unityhub.list ]; then
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/unityhub.gpg] https://hub.unity3d.com/linux/repos/deb stable main" > /etc/apt/sources.list.d/unityhub.list
fi
apt update -y
apt install -y unityhub

echo "==> Unity Hub installation complete. Launch with 'unityhub' or from your application menu."
