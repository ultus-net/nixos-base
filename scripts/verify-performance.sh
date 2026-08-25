#!/usr/bin/env bash
# Performance tuning verification script
# Checks that all performance optimizations are active

set -euo pipefail

echo "=============================================================="
echo "NixOS Performance Optimization Verification"
echo "=============================================================="
echo

echo "=== CPU Governor ==="
GOVERNOR=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
if [[ "$GOVERNOR" == "performance" ]]; then
  echo "[OK] CPU Governor: $GOVERNOR"
else
  echo "[FAIL] CPU Governor: $GOVERNOR (expected: performance)"
fi

echo -e "\n=== zram Status ==="
if zramctl 2>/dev/null | grep -q zram; then
  echo "[OK] zram is active:"
  zramctl
else
  echo "[FAIL] zram is NOT active"
fi

echo -e "\n=== I/O Schedulers ==="
if [[ -e /sys/block/nvme0n1/queue/scheduler ]]; then
  NVME_SCHED=$(cat /sys/block/nvme0n1/queue/scheduler | grep -o '\[.*\]' | tr -d '[]')
  if [[ "$NVME_SCHED" == "kyber" ]]; then
    echo "[OK] NVMe: $NVME_SCHED"
  else
    echo "[FAIL] NVMe: $NVME_SCHED (expected: kyber)"
  fi
fi

if [[ -e /sys/block/sda/queue/scheduler ]]; then
  SATA_SCHED=$(cat /sys/block/sda/queue/scheduler | grep -o '\[.*\]' | tr -d '[]')
  if [[ "$SATA_SCHED" == "mq-deadline" ]]; then
    echo "[OK] SATA: $SATA_SCHED"
  else
    echo "[WARN] SATA: $SATA_SCHED (expected: mq-deadline)"
  fi
fi

echo -e "\n=== TCP Congestion Control ==="
BBR=$(sysctl -n net.ipv4.tcp_congestion_control)
if [[ "$BBR" == "bbr" ]]; then
  echo "[OK] TCP Congestion Control: $BBR"
else
  echo "[FAIL] TCP Congestion Control: $BBR (expected: bbr)"
fi

QDISC=$(sysctl -n net.core.default_qdisc)
if [[ "$QDISC" == "fq" ]]; then
  echo "[OK] Queue Discipline: $QDISC"
else
  echo "[FAIL] Queue Discipline: $QDISC (expected: fq)"
fi

echo -e "\n=== Kernel Parameters ==="
CMDLINE=$(cat /proc/cmdline)

if echo "$CMDLINE" | grep -q "mitigations=off"; then
  echo "[OK] mitigations=off (performance mode)"
else
  echo "[FAIL] mitigations=off NOT found"
fi

if echo "$CMDLINE" | grep -q "ntsync.enable=1"; then
  echo "[OK] ntsync.enable=1 (Wine/Proton optimization)"
else
  echo "[FAIL] ntsync.enable=1 NOT found"
fi

if echo "$CMDLINE" | grep -q "processor.max_cstate=1"; then
  echo "[OK] processor.max_cstate=1 (low latency)"
else
  echo "[FAIL] processor.max_cstate=1 NOT found"
fi

echo -e "\n=== Memory & Swap ==="
echo "VM Swappiness: $(sysctl -n vm.swappiness) (target: 10)"
echo "VFS Cache Pressure: $(sysctl -n vm.vfs_cache_pressure) (target: 50)"
free -h

echo -e "\n=== Swap Priority ==="
swapon --show

echo -e "\n=== tmpfs Status ==="
df -h | grep tmpfs | grep -E '(tmp|run)' || echo "No tmpfs mounted for /tmp"

echo -e "\n=== Gamemode Status ==="
if systemctl is-enabled gamemode 2>/dev/null | grep -q enabled; then
  echo "[OK] Gamemode service is enabled"
  systemctl status gamemode --no-pager 2>/dev/null || echo "  (Not running - normal when no games active)"
else
  echo "[FAIL] Gamemode service is NOT enabled"
fi

echo -e "\n=== Boot Performance ==="
echo "Boot time analysis:"
systemd-analyze | head -1

echo -e "\n=============================================================="
echo "Verification Complete"
echo "=============================================================="
