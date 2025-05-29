# Secrets Management with Agenix

This directory contains encrypted secrets for your NixOS configuration using [agenix](https://github.com/ryantm/agenix).

## Setup

1. Generate an SSH key if you don't have one:
   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519
   ```

2. Add your public key to `secrets.nix`:
   ```nix
   {
     "your-secret" = {
       publicKeys = [ "ssh-ed25519 AAAA..." ];
       path = ./your-secret.age;
     };
   }
   ```

3. Create a new secret:
   ```bash
   agenix -e secrets/your-secret.age
   ```

4. Edit the secret:
   ```bash
   agenix -e secrets/your-secret.age
   ```

## Usage in NixOS Configuration

Add this to your host configuration:

```nix
{
  imports = [ inputs.agenix.nixosModules.default ];
  
  age.secrets.your-secret = {
    file = ./secrets/your-secret.age;
    mode = "0400";
    owner = "your-user";
    group = "your-group";
  };
}
```

## Security Notes

- Never commit private keys to the repository
- Keep your SSH private key secure
- Rotate secrets periodically
- Use appropriate file permissions 