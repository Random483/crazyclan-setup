# -------------------------------------------------------------------
# 40-dev-tools.sh
# Installs developer tools and related applications
# -------------------------------------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "==> 40-dev-tools: Installing developer tools"

# Update package lists
apt update -y

# ----------------------
# Python, pip, venv, Jupyter
echo "==> Installing Python, pip, venv, and Jupyter"
apt install -y python3 python3-pip python3-venv
pip3 install --upgrade pip
pip3 install jupyterlab notebook

# ----------------------
# VS Code (Microsoft repo)
echo "==> Installing Visual Studio Code"
if ! command -v code &>/dev/null; then
	wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /usr/share/keyrings/packages.microsoft.gpg
	echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list
	apt update -y
	apt install -y code
else
	echo "[INFO] VS Code already installed."
fi

# ----------------------
# MakeMKV (with Java 8)
echo "==> Installing MakeMKV and Java 8 (for MakeMKV)"
apt install -y openjdk-8-jre
# MakeMKV is not in apt; use official beta .deb
MAKEMKV_URL="https://www.makemkv.com/download/makemkv-bin-1.17.6.deb"
TMP_DEB="/tmp/makemkv.deb"
wget -O "$TMP_DEB" "$MAKEMKV_URL"
apt install -y "$TMP_DEB" || dpkg -i "$TMP_DEB" || echo "[WARN] MakeMKV install failed."
rm -f "$TMP_DEB"

# ----------------------
# Handbrake
echo "==> Installing Handbrake"
apt install -y handbrake handbrake-cli

# ----------------------
# 3D Printing: PrusaSlicer and Cura
echo "==> Installing PrusaSlicer and Cura"
apt install -y prusaslicer cura


# ----------------------
echo "==> Unity Hub install script available as scripts/41-unity-hub.sh. Run this script to install Unity Hub."
echo "[INFO] Editor install is managed via Unity Hub. See https://unity3d.com/get-unity/download for details."

echo "==> 40-dev-tools: Complete"
