### Install this nix-darwin config in a new mac

1. Install the package manager
    ```shell
    sh <(curl -L https://nixos.org/nix/install)
    ```
2. Clone this repository
   ```shell
   nix-shell -p git --run 'git clone https://gitlab.notyouraverage.dev/a.anand.91119/nix-config.git nix-config'
   ```
3. Install the nix-darwin flake configurations
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
