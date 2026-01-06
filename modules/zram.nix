{ config, lib, pkgs, ... }:
{
  # Module that exposes tunable options for zram swap.
  # Behaviour:
  # - If `machines.zram.enableAutoSize` is true (default), the service will
  #   compute the zram size as min(total_mem/2, machines.zram.maxSize).
  # - Otherwise, it will use `machines.zram.size` if set (>0).

  options = {
    machines.zram.enableAutoSize = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "When true, compute zram size as min(total RAM / 2, maxSize).";
    };

    machines.zram.maxSize = lib.mkOption {
      type = lib.types.int;
      default = 4294967296; # 4GiB
      description = "Upper bound for auto-computed zram size (bytes).";
    };

    machines.zram.size = lib.mkOption {
      type = lib.types.int;
      default = 0; # when 0 and enableAutoSize=true use heuristic
      description = "Explicit zram size in bytes (0 to use auto heuristic).";
    };

    machines.zram.compAlgorithm = lib.mkOption {
      type = lib.types.str;
      default = "lz4";
      description = "Preferred zram compression algorithm (if supported by kernel).";
    };
  };

  config = let
    auto = config.machines.zram.enableAutoSize;
    maxSize = config.machines.zram.maxSize;
    explicit = config.machines.zram.size;
    comp = config.machines.zram.compAlgorithm;
  in {
    systemd.services.zram-swap = {
      description = "Create zram swap device and enable swap";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
        Environment = [
          "ZRAM_AUTO=${toString auto}"
          "ZRAM_MAX=${toString maxSize}"
          "ZRAM_EXPLICIT=${toString explicit}"
          "ZRAM_COMP=${comp}"
        ];
        ExecStart = ''/bin/sh -c '\
          set -e; \
          modprobe zram num_devices=1 || true; \
          # Compute size (bytes): if explicit > 0 and auto is false use explicit; \
          # if auto is true compute min(total_mem/2, max). total_mem from /proc/meminfo (kB).\
          if [ "$ZRAM_AUTO" = "true" ]; then \
            MEM_KB=$(awk '/MemTotal:/{print $2}' /proc/meminfo || echo 0); \
            MEM_BYTES=$((MEM_KB * 1024)); \
            HALF=$((MEM_BYTES / 2)); \
            if [ $HALF -lt $ZRAM_MAX ]; then SIZE=$HALF; else SIZE=$ZRAM_MAX; fi; \
          else \
            if [ "$ZRAM_EXPLICIT" -gt 0 ]; then SIZE=$ZRAM_EXPLICIT; else SIZE=$ZRAM_MAX; fi; \
          fi; \
          # Try to set compression algorithm if supported\
          if [ -w /sys/block/zram0/comp_algorithm ]; then echo "$ZRAM_COMP" > /sys/block/zram0/comp_algorithm || true; fi; \
          # Write disksize if writable\
          if [ -w /sys/block/zram0/disksize ]; then echo "$SIZE" > /sys/block/zram0/disksize || true; fi; \
          # Setup swap\
          mkswap /dev/zram0 || true; \
          swapon /dev/zram0 || true' '';
      };
    };
  };
}
