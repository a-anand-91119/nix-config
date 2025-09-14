### Install this nix-darwin config in a new mac

1. Install the package manager
    ```shell
   curl -L https://nixos.org/nix/install | sh -s -- --daemon
    ```
2. Alternate approach to install nix (if existing installation is broken, this can be used to fix the existing
   installation)
    ```shell
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    ```
   > Also try https://docs.determinate.systems/ native mac os package for determinate linux

   > Uninstall this package using `/nix/nix-installer uninstall`

3. Clone this repository
   ```shell
   nix-shell -p git --run 'git clone https://gitlab.notyouraverage.dev/a.anand.91119/nix-config.git nix-config'
   ```
4. Install the nix-darwin flake configurations
   ```shell
   nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --flake ~/nix-config/#Anands-MacBook-Pro--M3-Pro
   ```

### Upgrading Nix in MacOS

Run the following command to update nix

```shell
sudo -i sh -c 'nix-channel --update && nix-env --install --attr nixpkgs.nix && launchctl remove org.nixos.nix-daemon && launchctl load /Library/LaunchDaemons/org.nixos.nix-daemon.plist'
```

### Updating the System

With Flakes, updating the system is straightforward. Simply execute the following commands.

```shell
# Update flake.lock
nix flake update

# Apply the updates
darwin-rebuild switch --flake ~/nix-config

# Or to update flake.lock & apply with one command (i.e. same as running "nix flake update" before)
darwin-rebuild switch --recreate-lock-file --flake ~/nix-config
```

### Troubleshooting

#### Incase of ssl Error, follow these steps

Check for an old symlink like this:

```shell
ls -la /etc/ssl/certs/ca-certificates.crt
```

If you have it (e.g. pointing to /etc/static/ssl/certs/ca-certificates.crt remove and create a new one.

TL;DR: Try this

```shell
sudo rm /etc/ssl/certs/ca-certificates.crt
sudo ln -s /nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt
```

> Ref: https://discourse.nixos.org/t/ssl-ca-cert-error-on-macos/31171/3


**Zsh: `compinit: insecure directories` Warning**

If you encounter a warning like `zsh compinit: insecure directories, run compaudit for list.` upon opening a new shell,
it means Zsh's completion system has found directories with permissions it considers insecure (often group-writable).
You can often fix this by running:

```shell
compaudit | xargs chmod g-w
```

if that doesn't dispaly any directories run this command and then check

```shell
chmod -R go-w "$(brew --prefix)/share"
```

This command finds the insecure directories reported by `compaudit` and removes group write permissions (`g-w`) from
them. You might need to run this with `sudo` if the directories are outside your home directory (e.g.,
`/usr/local/share/zsh`). If this persists, check the Nix configuration (`apps/zsh.nix` and system modules) for compinit
settings (like `ZSH_DISABLE_COMPFIX=true` or disabling system completions).

**Homebrew untap permission issue**
If any permission issue happens during darwin rebuild like
`Error: Permission denied @ apply2files - /opt/homebrew/Library/Taps/homebrew/homebrew-bundle`, then

Manually remove the symlink

```shell
sudo rm /opt/homebrew/Library/Taps/homebrew/homebrew-bundle
```

### Testing the Configuration

This repository includes automated tests to verify the correctness of the Nix configuration:

1. **GitLab CI/CD**: The `.gitlab-ci.yml` file defines a pipeline that:
    - Checks syntax of all Nix files
    - Verifies formatting with `nixpkgs-fmt`
    - Runs linting with `statix`
    - Performs a dry-run build of the configuration

2. **Local Testing**:
    - Run `./scripts/test.sh` to verify your configuration locally
    - Install git hooks with `./scripts/setup-hooks.sh` to automatically check syntax before commits

3. **Manual Checks**:
    - Check syntax of a single file: `nix-instantiate --parse path/to/file.nix`
    - Validate flake: `nix flake check`
    - Test build without applying: `nix build .#darwinConfigurations."Anands-MacBook-Pro--M3-Pro".system --dry-run`

### References

- https://nixos-and-flakes.thiscute.world/
- https://jorel.dev/NixOS4Noobs/intro.html
- Search for packages
    - Nix Packages: https://search.nixos.org/packages
    - NixHub: https://www.nixhub.io/
- Devbox: https://www.jetify.com/docs/devbox/
- nix-homebrew: https://github.com/zhaofengli/nix-homebrew
- nix-darwin: https://github.com/LnL7/nix-darwin
- Mac sample setup: https://github.com/torgeir/nix-darwin
- Github References:
    - https://github.com/ProfessorFlaw/NixDotfiles/blob/main/configuration.nix
    - https://github.com/mcdonc/.nixconfig/blob/master/videos/peruserperhost/script.rst
- Youtube Example: https://www.youtube.com/watch?v=e8vzW5Y8Gzg
- MyNixOS: https://mynixos.com/
- Config Example: https://sandstorm.de/blog/posts/my-first-steps-with-nix-on-mac-osx-as-homebrew-replacement/
