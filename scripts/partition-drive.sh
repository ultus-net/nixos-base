#!/usr/bin/env bash
# partition-drive.sh - Automatically partition a drive for NixOS installation
#
# Usage: sudo ./partition-drive.sh <device>
# Example: sudo ./partition-drive.sh /dev/sda

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fixed configuration
BOOT_SIZE="512M"
SWAP_SIZE="8G"
FILESYSTEM="ext4"
FIRMWARE_TYPE=""

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    cat << EOF
Usage: sudo $0 <device>

Automatically partition a drive for NixOS installation.

Arguments:
    device              Target device (e.g., /dev/sda, /dev/nvme0n1)

Examples:
    sudo $0 /dev/sda
    sudo $0 /dev/nvme0n1

Configuration (automatic):
    - Firmware detection: Auto-detect UEFI or BIOS
    - Boot partition: 512M
    - Swap partition: 8G
    - Root partition: Remaining space
    - Filesystem: ext4

WARNING: This will DESTROY ALL DATA on the target device!

EOF
}

# Function to detect firmware type
detect_firmware() {
    if [ -n "$FIRMWARE_TYPE" ]; then
        return
    fi
    
    if [ -d /sys/firmware/efi ]; then
        FIRMWARE_TYPE="uefi"
        print_info "Detected UEFI firmware"
    else
        FIRMWARE_TYPE="bios"
        print_info "Detected BIOS/Legacy firmware"
    fi
}

# Function to validate device
validate_device() {
    local device=$1
    
    if [ ! -b "$device" ]; then
        print_error "Device $device does not exist or is not a block device"
        exit 1
    fi
    
    # Check if device is mounted
    if mount | grep -q "^$device"; then
        print_error "Device $device has mounted partitions. Please unmount them first."
        exit 1
    fi
}

# Function to confirm action
confirm_action() {
    local device=$1
    
    echo ""
    print_warning "════════════════════════════════════════════════════════"
    print_warning "  WARNING: This will DESTROY ALL DATA on $device!"
    print_warning "════════════════════════════════════════════════════════"
    echo ""
    echo "Automatic configuration:"
    echo "  Device:       $device"
    echo "  Firmware:     $FIRMWARE_TYPE (auto-detected)"
    echo "  Boot:         $BOOT_SIZE"
    echo "  Swap:         $SWAP_SIZE"
    echo "  Root:         Remaining space"
    echo "  Filesystem:   $FILESYSTEM"
    echo ""
    
    read -p "Continue? (yes/no): " -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        print_info "Operation cancelled"
        exit 0
    fi
}

# Function to wipe device
wipe_device() {
    local device=$1
    
    print_info "Wiping device $device..."
    
    # Wipe any existing filesystem signatures
    wipefs -af "$device" || true
    
    # Zero out the beginning and end of the drive
    dd if=/dev/zero of="$device" bs=1M count=10 status=none || true
    dd if=/dev/zero of="$device" bs=1M seek=$(($(blockdev --getsz "$device") / 2048 - 10)) count=10 status=none || true
    
    # Create new partition table
    if [ "$FIRMWARE_TYPE" == "uefi" ]; then
        parted -s "$device" mklabel gpt
    else
        parted -s "$device" mklabel msdos
    fi
    
    print_success "Device wiped successfully"
}

# Function to create partitions for UEFI
create_uefi_partitions() {
    local device=$1
    
    print_info "Creating UEFI partitions..."
    
    # Boot partition (EFI System Partition)
    parted -s "$device" mkpart ESP fat32 1MiB "$BOOT_SIZE"
    parted -s "$device" set 1 esp on
    
    # Swap partition
    local swap_end
    swap_end=$(echo "$BOOT_SIZE $SWAP_SIZE" | awk '{
        boot=$1; swap=$2;
        gsub(/[^0-9.]/, "", boot); gsub(/[^0-9.]/, "", swap);
        boot_unit=substr($1, length($1)); swap_unit=substr($2, length($2));
        if (boot_unit == "G") boot=boot*1024;
        if (swap_unit == "G") swap=swap*1024;
        print boot+swap "M"
    }')
    parted -s "$device" mkpart primary linux-swap "$BOOT_SIZE" "$swap_end"
    
    # Root partition (rest of the disk)
    parted -s "$device" mkpart primary "$swap_end" 100%
    
    print_success "Partitions created"
}

# Function to create partitions for BIOS
create_bios_partitions() {
    local device=$1
    
    print_info "Creating BIOS partitions..."
    
    # Boot partition
    parted -s "$device" mkpart primary ext4 1MiB "$BOOT_SIZE"
    parted -s "$device" set 1 boot on
    
    # Swap partition
    local swap_end
    swap_end=$(echo "$BOOT_SIZE $SWAP_SIZE" | awk '{
        boot=$1; swap=$2;
        gsub(/[^0-9.]/, "", boot); gsub(/[^0-9.]/, "", swap);
        boot_unit=substr($1, length($1)); swap_unit=substr($2, length($2));
        if (boot_unit == "G") boot=boot*1024;
        if (swap_unit == "G") swap=swap*1024;
        print boot+swap "M"
    }')
    parted -s "$device" mkpart primary linux-swap "$BOOT_SIZE" "$swap_end"
    
    # Root partition (rest of the disk)
    parted -s "$device" mkpart primary "$swap_end" 100%
    
    print_success "Partitions created"
}

# Function to get partition names
get_partition_name() {
    local device=$1
    local num=$2
    
    # Handle different device naming schemes
    if [[ $device =~ ^/dev/(nvme|loop|mmcblk) ]]; then
        echo "${device}p${num}"
    else
        echo "${device}${num}"
    fi
}

# Function to format partitions
format_partitions() {
    local device=$1
    
    print_info "Formatting partitions..."
    
    # Wait for kernel to register partitions
    sleep 2
    partprobe "$device" || true
    sleep 2
    
    local boot_part=$(get_partition_name "$device" 1)
    local swap_part=$(get_partition_name "$device" 2)
    local root_part=$(get_partition_name "$device" 3)
    
    # Format boot partition
    if [ "$FIRMWARE_TYPE" == "uefi" ]; then
        print_info "Formatting boot partition as FAT32..."
        mkfs.fat -F 32 -n BOOT "$boot_part"
    else
        print_info "Formatting boot partition as ext4..."
        mkfs.ext4 -L boot "$boot_part"
    fi
    
    # Format swap partition
    print_info "Creating swap on $swap_part..."
    mkswap -L swap "$swap_part"
    
    # Format root partition
    print_info "Formatting root partition as $FILESYSTEM..."
    mkfs.ext4 -L nixos "$root_part"
    
    print_success "All partitions formatted"
}

# Function to mount partitions
mount_partitions() {
    local device=$1
    
    print_info "Mounting partitions..."
    
    local boot_part=$(get_partition_name "$device" 1)
    local swap_part=$(get_partition_name "$device" 2)
    local root_part=$(get_partition_name "$device" 3)
    
    # Mount root
    print_info "Mounting root partition..."
    mount "$root_part" /mnt
    
    # Create and mount boot
    mkdir -p /mnt/boot
    print_info "Mounting boot partition..."
    mount "$boot_part" /mnt/boot
    
    # Enable swap
    print_info "Enabling swap..."
    swapon "$swap_part"
    
    print_success "All partitions mounted"
}

# Function to show next steps
show_next_steps() {
    local device=$1
    
    local boot_part=$(get_partition_name "$device" 1)
    local swap_part=$(get_partition_name "$device" 2)
    local root_part=$(get_partition_name "$device" 3)
    
    echo ""
    print_success "════════════════════════════════════════════════════════"
    print_success "  Partitioning complete!"
    print_success "════════════════════════════════════════════════════════"
    echo ""
    echo "Partition layout:"
    echo "  Boot:  $boot_part → /mnt/boot (512M, $([ "$FIRMWARE_TYPE" == "uefi" ] && echo "FAT32" || echo "ext4"))"
    echo "  Swap:  $swap_part (8G)"
    echo "  Root:  $root_part → /mnt (remaining space, ext4)"
    echo ""
    echo "Your system is ready for NixOS installation!"
    echo ""
    echo "Next steps:"
    echo ""
    echo "1. Generate hardware configuration:"
    echo "   nixos-generate-config --root /mnt"
    echo ""
    echo "2. Edit configuration:"
    echo "   nano /mnt/etc/nixos/configuration.nix"
    echo ""
    echo "3. Install NixOS:"
    echo "   nixos-install"
    echo ""
    echo "4. After installation, reboot:"
    echo "   reboot"
    echo ""
}

# Parse command line arguments
if [ $# -eq 0 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    show_usage
    exit 0
fi

DEVICE="$1"

# Check if device was provided
if [ -z "$DEVICE" ]; then
    print_error "No device specified"
    show_usage
    exit 1
fi

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "This script must be run as root"
    exit 1
fi

# Main execution
echo ""
print_info "═══════════════════════════════════════════════════════════"
print_info "  NixOS Automatic Disk Partitioning Script"
print_info "═══════════════════════════════════════════════════════════"
echo ""

# Validate inputs
validate_device "$DEVICE"

# Detect firmware type
detect_firmware

# Confirm action
confirm_action "$DEVICE"

# Execute partitioning steps
print_info "Starting partitioning process..."
wipe_device "$DEVICE"

if [ "$FIRMWARE_TYPE" == "uefi" ]; then
    create_uefi_partitions "$DEVICE"
else
    create_bios_partitions "$DEVICE"
fi

format_partitions "$DEVICE"
mount_partitions "$DEVICE"

# Show next steps
show_next_steps "$DEVICE"

print_success "Script completed successfully!"
