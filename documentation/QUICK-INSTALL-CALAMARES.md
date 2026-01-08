# Quick Install Guide - COSMIC via Calamares (Easiest Method)

This is the **easiest** way to install your COSMIC workstation. Use the GUI installer first, then apply your configuration.

## ⚠️ Important Warnings

**BEFORE YOU START:**
1. **Your Calamares settings will be replaced** - Don't spend too much time customizing the Calamares installation, we'll replace it with the flake configuration
2. **Password required after install** - This flake uses empty passwords by default. After rebooting, you'll need to set your password with `sudo passwd username`
3. **Username flexibility** - You can use "hunter" during Calamares or your own name, but you'll need to update the flake configs either way
4. **Don't reboot immediately** - After Calamares finishes, stay in the live environment to apply the flake

## Why This Method?

✅ **No space issues** - Calamares installs a minimal base first  
✅ **GUI installer** - Easy partitioning, user setup, etc.  
✅ **No manual partitioning** - Point and click  
✅ **Works every time** - No RAM limitations  

---

## Step 1: Boot NixOS Live ISO with GUI

Use the **graphical ISO** (not minimal) which includes Calamares.

Boot from USB and wait for the desktop to load.

---

## Step 2: Run Calamares Installer

1. Click the "Install NixOS" icon on the desktop
2. Follow the GUI installer:
   - Choose your language
   - Select your timezone
   - **Partition your disk** (automatic or manual)
   - **Create your user** (you can use "hunter" or your own name)
   - Set your passwords
   - Choose "No desktop" or any minimal desktop (we'll replace it)

3. Let it install (10-15 minutes)

4. **DO NOT REBOOT YET!** Click "Done" but stay in the live environment.

---

## Step 3: Replace Configuration Before First Boot

Now we'll replace the default config with your COSMIC setup:

```bash
# Mount your new installation
sudo mount /dev/sda2 /mnt  # Adjust partition if needed
sudo mount /dev/sda1 /mnt/boot  # Adjust partition if needed

# Backup the Calamares config
sudo mv /mnt/etc/nixos /mnt/etc/nixos.backup

# Clone your config
cd /mnt/etc
sudo git clone https://github.com/ultus-net/nixos-base.git nixos

# Copy the hardware config that Calamares generated
sudo cp /mnt/etc/nixos.backup/hardware-configuration.nix /mnt/etc/nixos/machines/

# Edit tower.nix to match your username from Calamares
sudo nano /mnt/etc/nixos/machines/tower.nix
# Change "hunter" to your username if different

# Rebuild the system with your config
sudo nixos-enter --root /mnt
nixos-rebuild switch --flake /etc/nixos#tower
exit
```

---

## Step 4: Reboot

```bash
sudo reboot
```

Remove the USB drive. Your system will boot into COSMIC with all gaming/multimedia packages!

---

## Alternative: Apply Config After First Boot (Even Easier!)

If you prefer to boot into the Calamares system first:

1. **Complete Calamares install** with default settings
2. **Reboot** into your new system
3. **Login** with the user you created
4. **Run these commands**:

```bash
# Clone your config
cd ~
git clone https://github.com/ultus-net/nixos-base.git

# Backup Calamares config
sudo mv /etc/nixos /etc/nixos.backup

# Link your config
sudo ln -s ~/nixos-base /etc/nixos

# Copy hardware config
sudo cp /etc/nixos.backup/hardware-configuration.nix /etc/nixos/machines/

# Edit tower.nix to match your username
nano ~/nixos-base/machines/tower.nix
# Change ALL instances of "hunter" to YOUR username

# Apply your config
sudo nixos-rebuild switch --flake /etc/nixos#tower

# Reboot to COSMIC
sudo reboot
```

That's it! After reboot you'll have your full COSMIC gaming workstation.

---

## Advantages of This Method

1. **No space issues** - Calamares installs minimal base (~5GB)
2. **No manual partitioning** - GUI handles everything
3. **User already created** - Just update the config to match
4. **Hardware config auto-generated** - Guaranteed to work
5. **Can fix mistakes** - Boot into working system if something breaks

---

## Troubleshooting

### "flake evaluation failed" when rebuilding

Make sure you updated the username in `tower.nix`:
```bash
# Check what username Calamares created
whoami

# Edit tower.nix and change "hunter" to your username
nano ~/nixos-base/machines/tower.nix
```

Look for these sections and update:
```nix
machines.users = {
  YOUR_USERNAME_HERE = {  # Change this
    ...
  };
};

home-manager.users.YOUR_USERNAME_HERE = import ../home/hunter.nix;  # Change this
```

### Can't boot after applying config

Reboot into the system. At boot, press a key to see the boot menu. Select the previous generation (the Calamares one). Then fix your config and retry.

### Want to keep Calamares desktop + add COSMIC

Don't replace the config entirely. Instead:
1. Keep the Calamares `/etc/nixos`
2. Just add COSMIC: `sudo nano /etc/nixos/configuration.nix`
3. Import the cosmic profile:
```nix
imports = [
  ./hardware-configuration.nix
  ~/nixos-base/profiles/cosmic.nix
];
```

---

## What Gets Installed

Same as the manual method:
- COSMIC Desktop
- Full gaming setup (Steam, Lutris, Heroic, MangoHud)
- Multimedia tools (OBS, Kdenlive, Audacity, GIMP)
- Virtualization (VirtualBox, virt-manager)
- Container support (Docker, Podman)
- Development tools

---

## Need Help?

- Check `QUICK-INSTALL-COSMIC.md` for manual installation
- Check `INSTALL.md` for detailed documentation
- Check the NixOS manual: https://nixos.org/manual/nixos/stable/

---

**Enjoy your COSMIC NixOS system - the easy way!** 🚀
