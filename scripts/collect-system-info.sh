#!/usr/bin/env sh
# Portable system information collector for sharing repo-relevant context.
# Designed to run on a host where you cannot install new packages (atomic distro).
# Writes a tarball to /tmp; inspect contents before sharing. Avoids reading secrets.

set -eu

OUTDIR="/tmp/nixos-base-system-info-$(date +%s)"
mkdir -p "$OUTDIR"

save() {
  name="$1"
  shift
  echo "==> Collecting $name"
  (
    echo "# $name"
    "$@" 2>&1 || true
  ) > "$OUTDIR/$name.txt"
}

# Basic system identity
save os-release cat /etc/os-release
save uname sh -c 'uname -a'
save hostname sh -c 'hostnamectl 2>/dev/null || hostname'

# Kernel and boot
save cmdline sh -c 'cat /proc/cmdline'
save mounts sh -c 'mount'
save fstab sh -c 'cat /etc/fstab 2>/dev/null || true'

# CPU / memory
if command -v lscpu >/dev/null 2>&1; then
  save lscpu lscpu
else
  save cpuhead sh -c 'head -n 20 /proc/cpuinfo'
fi
save meminfo sh -c 'cat /proc/meminfo'
save df sh -c 'df -h'

# Block devices and filesystems
if command -v lsblk >/dev/null 2>&1; then
  save lsblk sh -c 'lsblk -f'
fi
save mountpoints sh -c 'if command -v findmnt >/dev/null 2>&1; then findmnt -o TARGET,SOURCE,FSTYPE,SIZE || true; else echo "findmnt not available"; fi'

# Network
if command -v ip >/dev/null 2>&1; then
  save ip_addr sh -c 'ip addr'
  save ip_route sh -c 'ip route'
else
  save ifconfig sh -c 'ifconfig 2>/dev/null || true'
fi

# Services (systemd)
if command -v systemctl >/dev/null 2>&1; then
  save systemctl_version sh -c 'systemctl --version'
  save systemctl_enabled sh -c 'systemctl list-unit-files --type=service --state=enabled 2>/dev/null || true'
fi

# Users and login
save current_user sh -c 'id "${USER:-$(whoami)}" 2>/dev/null || id'
save passwd_users sh -c 'getent passwd | awk -F: '\''$3>=1000 && $1!="nobody"{print $1":"$6}'\'' 2>/dev/null || true'

# Desktop / session detection (best-effort)
save session_env sh -c 'printf "XDG_SESSION_TYPE=%s\n" "${XDG_SESSION_TYPE:-}"; env | grep -E "WAYLAND|DISPLAY|DESKTOP_SESSION|XDG_CURRENT_DESKTOP" || true'
save running_de_session sh -c 'ps -e -o comm | egrep -i "gnome|plasmashell|kwin|sway|Xorg|Xwayland" || true'

# Graphics
if command -v lspci >/dev/null 2>&1; then
  save lspci sh -c 'lspci -nnk | egrep -i "vga|3d|display" -A3 || true'
else
  save drm_status sh -c 'ls /sys/class/drm 2>/dev/null || true; for d in /sys/class/drm/*/status 2>/dev/null; do echo "$d:"; cat "$d"; done || true'
fi

# Audio
if command -v pactl >/dev/null 2>&1; then
  save pactl_info sh -c 'pactl info 2>/dev/null || true'
fi
save lsmod_audio sh -c 'lsmod | egrep "snd|pipewire|pulseaudio|jack" || true'

# Nix/NixOS related (if present)
save etc_nixos sh -c 'ls -la /etc/nixos 2>/dev/null || true'
save nix_versions sh -c 'command -v nix >/dev/null 2>&1 && nix --version || echo "nix not installed"'

# Home Manager / user dotfiles (best-effort)
save home_manager_paths sh -c 'awk -F: '\''$3>=1000 && $1!="nobody"{print $1}'\'' /etc/passwd 2>/dev/null | while read u; do printf "--- %s ---\n" "$u"; home=$(getent passwd "$u" | cut -d: -f6); printf "home: %s\n" "$home"; ls -la "$home/.config/nixpkgs" 2>/dev/null || true; ls -la "$home/.config/home-manager" 2>/dev/null || true; done || true'

echo "Packaging results into tarball..."
TARBALL="${OUTDIR}.tar.gz"
tar -C /tmp -czf "$TARBALL" "$(basename "$OUTDIR")"

echo "Done. Collected info is in: $TARBALL"
echo "Inspect it before sharing. Do NOT share secrets (passwords, private keys)."
echo "If you want, upload the tarball or paste specific files (e.g. $OUTDIR/lscpu.txt)."

exit 0
