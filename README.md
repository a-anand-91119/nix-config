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