# Secrets Management in NixOS

Managing secrets (API keys, passwords, certificates) in a declarative configuration system like NixOS requires special care. Here are several approaches.

## ⚠️ What NOT to Do

**NEVER** commit secrets directly in your Nix files:

```nix
# ❌ BAD - secrets in plaintext
services.myservice = {
  enable = true;
  apiKey = "sk_live_abc123def456";  # NEVER DO THIS
};
```

## Recommended Approaches

### 1. Environment Variables (Quick & Simple)

For development or non-critical secrets:

**.env file (gitignored):**
```bash
# .env
MY_API_KEY="your-secret-here"
DATABASE_PASSWORD="super-secret"
```

**In your configuration:**
```nix
systemd.services.myservice = {
  serviceConfig = {
    EnvironmentFile = "/etc/nixos/.env";
  };
};
```

**Pros:** Simple, familiar pattern  
**Cons:** Less secure, manual file management

### 2. sops-nix (Recommended for Production)

[sops-nix](https://github.com/Mic92/sops-nix) encrypts secrets with age or GPG.

**Installation:**

Add to `flake.nix`:
```nix
{
  inputs = {
    sops-nix.url = "github:Mic92/sops-nix";
  };
  
  outputs = { self, nixpkgs, sops-nix, ... }: {
    nixosConfigurations.my-machine = nixpkgs.lib.nixosSystem {
      modules = [
        sops-nix.nixosModules.sops
        # ... your other modules
      ];
    };
  };
}
```

**Create a key:**
```bash
# Install age
nix-shell -p age

# Generate key
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt

# Note the public key from the output
```

**Create .sops.yaml:**
```yaml
keys:
  - &admin_key age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p

creation_rules:
  - path_regex: secrets/[^/]+\.yaml$
    key_groups:
      - age:
          - *admin_key
```

**Create encrypted secrets:**
```bash
# Create secrets file
sops secrets/production.yaml

# Add secrets (opens $EDITOR):
api_key: sk_live_abc123def456
database_password: super-secret-password
```

**Use in configuration:**
```nix
{
  sops.defaultSopsFile = ./secrets/production.yaml;
  sops.age.keyFile = "/root/.config/sops/age/keys.txt";
  
  sops.secrets.api_key = {
    owner = "myuser";
  };
  
  sops.secrets.database_password = {};
  
  # Reference in services
  systemd.services.myservice = {
    serviceConfig = {
      LoadCredential = "api_key:${config.sops.secrets.api_key.path}";
    };
  };
}
```

**Pros:** Encrypted, version-controllable, multi-user support  
**Cons:** More setup, requires key management

### 3. agenix (Alternative to sops-nix)

[agenix](https://github.com/ryantm/agenix) is another age-based solution, simpler than sops.

**Installation:**

Add to `flake.nix`:
```nix
{
  inputs.agenix.url = "github:ryantm/agenix";
  
  outputs = { self, nixpkgs, agenix, ... }: {
    nixosConfigurations.my-machine = nixpkgs.lib.nixosSystem {
      modules = [
        agenix.nixosModules.default
        # ... your other modules
      ];
    };
  };
}
```

**Create secrets:**
```bash
# Generate host key (if not exists)
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519

# Create secrets.nix with public keys
cat > secrets/secrets.nix << 'EEOF'
let
  user = "ssh-ed25519 AAAA...your-public-key";
  system = "ssh-ed25519 AAAA...system-public-key";
in {
  "api_key.age".publicKeys = [ user system ];
  "database_password.age".publicKeys = [ user system ];
}
EEOF

# Encrypt a secret
agenix -e secrets/api_key.age
```

**Use in configuration:**
```nix
{
  age.secrets.api_key.file = ./secrets/api_key.age;
  
  systemd.services.myservice = {
    serviceConfig = {
      LoadCredential = "api_key:${config.age.secrets.api_key.path}";
    };
  };
}
```

**Pros:** Simpler than sops, SSH key integration  
**Cons:** Less features than sops

### 4. NixOS Activation Scripts (For Simple Cases)

For secrets that don't need encryption in the repo:

```nix
system.activationScripts.setupSecrets = ''
  if [ ! -f /etc/secrets/api_key ]; then
    echo "⚠️  Please create /etc/secrets/api_key"
    exit 1
  fi
'';

systemd.services.myservice = {
  serviceConfig = {
    LoadCredential = "api_key:/etc/secrets/api_key";
  };
};
```

**Pros:** No extra dependencies  
**Cons:** Manual management, not in version control

## Comparison Matrix

| Method | Encrypted | In Git | Complexity | Best For |
|--------|-----------|--------|------------|----------|
| Environment Files | ❌ | ❌ | Low | Development |
| sops-nix | ✅ | ✅ | High | Production, teams |
| agenix | ✅ | ✅ | Medium | Personal systems |
| Manual Files | ❌ | ❌ | Low | Quick setups |

## Best Practices

1. **Never commit unencrypted secrets** — use `.gitignore`
2. **Rotate secrets regularly** — especially after team changes
3. **Use different secrets per environment** — dev/staging/prod
4. **Limit secret permissions** — use `owner` and `mode` options
5. **Document your approach** — in your README or this file
6. **Backup encryption keys** — store securely offline
7. **Use systemd credentials** — `LoadCredential` when possible

## Quick Start for This Repo

1. **Choose your method** (recommend sops-nix for production)
2. **Add input to flake.nix** 
3. **Generate keys** and store securely
4. **Create secrets file** (gitignored or encrypted)
5. **Reference in modules** using `config.sops.secrets.*` or similar
6. **Test** before deploying to production

## Resources

- [sops-nix Documentation](https://github.com/Mic92/sops-nix)
- [agenix Documentation](https://github.com/ryantm/agenix)
- [NixOS Wiki: Secrets](https://nixos.wiki/wiki/Comparison_of_secret_managing_schemes)
- [age Encryption](https://github.com/FiloSottile/age)

## Example: Adding sops-nix to This Repo

```bash
# 1. Update flake.nix inputs
nix flake lock --update-input sops-nix

# 2. Generate age key
nix-shell -p age
age-keygen -o ~/.config/sops/age/keys.txt

# 3. Create .sops.yaml with your public key

# 4. Create secrets directory
mkdir -p secrets

# 5. Create first secret file
nix-shell -p sops
sops secrets/personal.yaml

# 6. Add to your machine config:
# sops.defaultSopsFile = ./secrets/personal.yaml;
# sops.age.keyFile = "/var/lib/sops/age/keys.txt";

# 7. Deploy
sudo nixos-rebuild switch --flake .#your-machine
```
