# -------------------------------------------------------------------
# 40-dev-tools.sh
# Installs developer tools and related applications
# -------------------------------------------------------------------


set -euo pipefail

# Load logging functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$ROOT_DIR/lib/logging.sh"
log_stage "40-dev-tools.sh"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "==> 40-dev-tools: Installing developer tools"

# Update package lists
apt update -y

# ----------------------
# Python, pip, venv, Jupyter
echo "==> Installing Python, pip, venv, and JupyterLab/Notebook (via apt)"
apt install -y python3 python3-pip python3-venv pipx
pipx install jupyterlab

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
###############################################################
# MakeMKV (with Java 8)
# Note: Java 8 is installed system-wide via apt because MakeMKV
# only needs a single version and does not require per-user or
# per-instance Java version switching. For MultiMC (Minecraft),
# SDKMAN is used in 30-family-tools.sh to allow users to install
# and switch between multiple Java versions as needed.
###############################################################
echo "==> Installing MakeMKV and Java 8 (for MakeMKV)"
apt install -y openjdk-8-jre
# Install build prerequisites for MakeMKV
apt install -y build-essential pkg-config libc6-dev libssl-dev libexpat1-dev libavcodec-dev libgl1-mesa-dev qtbase5-dev zlib1g-dev

# Download and build MakeMKV from source
cd /tmp
wget https://www.makemkv.com/download/makemkv-oss-1.18.3.tar.gz
wget https://www.makemkv.com/download/makemkv-bin-1.18.3.tar.gz
tar xzf makemkv-oss-1.18.3.tar.gz
tar xzf makemkv-bin-1.18.3.tar.gz

# Build OSS
cd makemkv-oss-1.18.3
./configure
make
sudo make install

# Build BIN
cd ../makemkv-bin-1.18.3
make
sudo make install

cd ~

# ----------------------
# Handbrake
echo "==> Installing Handbrake"
apt install -y handbrake handbrake-cli

# ----------------------
echo "==> Unity Hub install script available as scripts/41-unity-hub.sh. Run this script to install Unity Hub."
echo "[INFO] Editor install is managed via Unity Hub. See https://unity3d.com/get-unity/download for details."

echo "==> 40-dev-tools: Complete"
