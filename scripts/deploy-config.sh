#!/usr/bin/env bash
set -euo pipefail

# deploy-config.sh - Sync local nixos-base repository to /etc/nixos

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Preserve original user's home directory when running with sudo
if [ -n "${SUDO_USER:-}" ]; then
    REAL_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    REAL_HOME="$HOME"
fi

# Default source path
SOURCE="${REAL_HOME}/Documents/nixos-base"
TARGET="/etc/nixos"

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  NixOS Configuration Deployment${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

# Check if source directory exists
if [ ! -d "$SOURCE" ]; then
    echo -e "${RED}Error: Source directory not found: ${SOURCE}${NC}"
    exit 1
fi

# Check if we're running as root (needed for /etc/nixos)
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}This script requires root privileges to write to /etc/nixos${NC}"
    echo -e "${YELLOW}Re-running with sudo...${NC}"
    exec sudo bash "$0" "$@"
fi

echo -e "${YELLOW}Source: ${SOURCE}${NC}"
echo -e "${YELLOW}Target: ${TARGET}${NC}"
echo ""

# Show what would change (dry-run first)
echo -e "${BLUE}Checking for changes...${NC}"
if ! rsync -ani --delete \
    --exclude='.git' \
    --exclude='result*' \
    --exclude='.direnv' \
    --exclude='.envrc' \
    "${SOURCE}/" "${TARGET}/" | head -20; then
    echo -e "${RED}Failed to check changes${NC}"
    exit 1
fi

echo ""
read -p "$(echo -e ${YELLOW}Continue with deployment? [y/N]:${NC} )" -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Deployment cancelled${NC}"
    exit 0
fi

# Backup existing /etc/nixos (just in case)
BACKUP_DIR="/etc/nixos-backup-$(date +%Y%m%d-%H%M%S)"
echo ""
echo -e "${BLUE}Creating backup: ${BACKUP_DIR}${NC}"
cp -a "${TARGET}" "${BACKUP_DIR}"

# Perform the sync
echo -e "${BLUE}Syncing configuration files...${NC}"
if rsync -av --delete \
    --exclude='.git' \
    --exclude='result*' \
    --exclude='.direnv' \
    --exclude='.envrc' \
    "${SOURCE}/" "${TARGET}/"; then
    echo ""
    echo -e "${GREEN}Configuration deployed successfully${NC}"
else
    echo ""
    echo -e "${RED}Deployment failed${NC}"
    echo -e "${YELLOW}Restoring from backup...${NC}"
    rm -rf "${TARGET}"
    cp -a "${BACKUP_DIR}" "${TARGET}"
    echo -e "${YELLOW}Backup restored${NC}"
    exit 1
fi

# Show next steps
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Next Steps:${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${YELLOW}1.${NC} Review changes (optional):"
echo -e "     ${BLUE}git -C ${TARGET} status${NC}"
echo ""
echo -e "  ${YELLOW}2.${NC} Test the configuration:"
echo -e "     ${BLUE}sudo nixos-rebuild test --flake ${TARGET}#tower${NC}"
echo ""
echo -e "  ${YELLOW}3.${NC} Apply the configuration:"
echo -e "     ${BLUE}sudo nixos-rebuild switch --flake ${TARGET}#tower${NC}"
echo ""
echo -e "  ${YELLOW}4.${NC} Or build and switch in one go:"
echo -e "     ${BLUE}sudo nixos-rebuild switch --flake ${TARGET}#tower${NC}"
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
