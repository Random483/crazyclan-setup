#!/usr/bin/env bash
# -------------------------------------------------------------------
# 51-docker.sh
# Installs Docker and Docker Compose
# -------------------------------------------------------------------

set -euo pipefail

# Load logging functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$ROOT_DIR/lib/logging.sh"
log_stage "51-docker.sh"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Remove old versions if present
apt remove -y docker docker-engine docker.io containerd runc || true

# Install dependencies
apt update -y
apt install -y ca-certificates curl gnupg lsb-release

# Add Docker’s official GPG key
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release && echo "$ID")/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
ARCH=$(dpkg --print-architecture)
RELEASE=$(lsb_release -cs)
echo \
  "deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$(. /etc/os-release && echo $ID) $RELEASE stable" \
  > /etc/apt/sources.list.d/docker.list

apt update -y

# Install Docker Engine, CLI, containerd, and Compose plugin
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable and start Docker
systemctl enable docker
systemctl start docker


# ----------------------
# Portainer Agent (for remote Docker management)
echo "==> Installing Portainer Agent for remote management via Portainer UI"
docker run -d \
  -p 9001:9001 \
  --name portainer_agent \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /var/lib/docker/volumes:/var/lib/docker/volumes \
  portainer/agent:latest


echo "==> 51-docker: Docker, Docker Compose, and Portainer Agent installed. Add users to 'docker' group as needed."

# Portainer UI instructions
HOSTNAME=$(hostname -f)
echo "==> To add this server to your Portainer UI:"
echo "   1. Open Portainer UI on your main server."
echo "   2. Go to 'Endpoints' and click 'Add Endpoint'."
echo "   3. Choose 'Agent' as the environment type."
echo "   4. Enter the address: $HOSTNAME:9001"
echo "   5. Save and connect."
echo "==> Ensure port 9001 is open and accessible from your Portainer server."
