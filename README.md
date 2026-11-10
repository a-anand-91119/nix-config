# nix-darwin config

One flake, multiple Macs. Each Mac is a "host" with its own file in `hosts/`:

| Host (flake output) | Host file | Profile |
| --- | --- | --- |
| `Anands-MacBook-Pro--M3-Pro` | [hosts/personal-macbook.nix](hosts/personal-macbook.nix) | personal: full toolset, JDKs, desktop apps |
| `work-mini` | [hosts/work-mini.nix](hosts/work-mini.nix) | work: minimal terminal/Git baseline, Alacritty, Podman |

In the commands below, replace `<host>` with the flake output name from this table.

---

## Install on a fresh Mac

1. **Install Xcode command-line tools** (if not already there)
   ```shell
   xcode-select --install
   ```

2. **Install Nix**
   ```shell
   curl -L https://nixos.org/nix/install | sh -s -- --daemon
   ```
   Alternative: the Determinate installer. It can also fix a broken existing install:
   ```shell
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```
   > If you use Determinate, set `manageNix = false` in your host file **before** step 5.
   > Determinate also has a native macOS package: https://docs.determinate.systems/
   > Uninstall Determinate with `sudo /nix/nix-installer uninstall`

   Open a new terminal, then check that `nix --version` works.

3. **Clone this repository**
   ```shell
   nix-shell -p git --run 'git clone https://gitlab.notyouraverage.dev/a.anand.91119/nix-config.git ~/nix-config'
   cd ~/nix-config
   ```

4. **Check the host file** (`hosts/<file>.nix`)
   - `username` must match `id -un` on this Mac.
   - `git.name` / `git.email` set the commit identity.
   - `migrateHomebrew = false` for a Mac with no Homebrew yet. Set it to `true` only if
     you want nix-homebrew to take over an existing Homebrew install.
   - Setting up a Mac that isn't in the table? See [Add a new Mac](#add-a-new-mac).

5. **Build and apply the config**
   ```shell
   sudo nix --extra-experimental-features 'nix-command flakes' run \
     --inputs-from . nix-darwin#darwin-rebuild -- switch --flake ~/nix-config#<host>
   ```
   Optional dry run first (builds without activating): use `build` instead of `switch`
   and drop the `sudo`.

6. **Open a new terminal.** From now on, rebuild with the `dr` alias.

---

## Daily use

```shell
dr                     # rebuild + apply this Mac's config
```

`dr` expands to `sudo darwin-rebuild switch --flake ~/nix-config#<this host>`, so the
same alias works on every Mac. It applies the local checkout; run `git pull` first if you
want remote changes.

### Updating the system

```shell
cd ~/nix-config
nix flake update       # update flake.lock
dr                     # apply

# or update the lock and apply in one go
sudo darwin-rebuild switch --recreate-lock-file --flake ~/nix-config#<host>
```

### Upgrading Nix

With `manageNix = true` (default), Nix itself comes from the locked nixpkgs, so
`nix flake update` + `dr` upgrades it as well.

With `manageNix = false` (Determinate or a standalone install), upgrade outside this repo:

```shell
sudo -i sh -c 'nix-channel --update && nix-env --install --attr nixpkgs.nix && launchctl remove org.nixos.nix-daemon && launchctl load /Library/LaunchDaemons/org.nixos.nix-daemon.plist'
```

---

## Add a new Mac

1. Copy an existing host file whose profile matches what you want:
   ```shell
   cp hosts/work-mini.nix hosts/<new-name>.nix
   ```
   Edit `name`, `username`, `profile` (`"personal"` or `"work"`) and `git`.
2. Register it in `flake.nix`:
   ```nix
   newmac = mkHost (import ./hosts/<new-name>.nix);
   # ...
   darwinConfigurations = {
     # ...
     "<new-name>" = newmac;
   };
   ```
   Also add it to `checks.aarch64-darwin` so CI evaluates it.
3. `git add` the new file. Flakes only see files tracked by Git.
4. Run step 5 of the install with `#<new-name>`.

---

## Troubleshooting

### `dr`, `darwin-rebuild` or `nix` missing after a macOS update

macOS updates overwrite `/etc/zshrc`, which deletes the lines that load Nix.

```shell
# 1. load nix into this shell
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# 2. rebuild without darwin-rebuild on PATH
cd ~/nix-config
sudo nix --extra-experimental-features 'nix-command flakes' run \
  --inputs-from . nix-darwin#darwin-rebuild -- switch --flake .#<host>
```

If step 2 refuses to overwrite `/etc/zshrc`, move Apple's copy aside and run it again:
```shell
sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin.$(date +%Y%m%d)
```

Open a new terminal; `dr` is back.

### SSL error

Check for an old symlink:

```shell
ls -la /etc/ssl/certs/ca-certificates.crt
```

If it points to `/etc/static/ssl/certs/ca-certificates.crt`, delete it and point it at
the Nix bundle:

```shell
sudo rm /etc/ssl/certs/ca-certificates.crt
sudo ln -s /nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt
```

> Ref: https://discourse.nixos.org/t/ssl-ca-cert-error-on-macos/31171/3

Behind a corporate TLS proxy, set `NIX_SSL_CERT_FILE` (client) and `ssl-cert-file`
(daemon, via `nix.settings` in `modules/nix-settings.nix`) to the company CA bundle.

### Zsh: `compinit: insecure directories`

```shell
compaudit | xargs chmod g-w
```

If `compaudit` lists nothing, run this, then open a new shell:

```shell
chmod -R go-w "$(brew --prefix)/share"
```

Use `sudo` if the reported directories are outside your home directory.

### Homebrew untap permission error

For an error during rebuild like
`Error: Permission denied @ apply2files - /opt/homebrew/Library/Taps/homebrew/homebrew-bundle`:

```shell
sudo rm /opt/homebrew/Library/Taps/homebrew/homebrew-bundle
```

Taps are declared in `lib/mk-host.nix` (`mutableTaps = false`). If the error keeps
coming back, fix the tap list there instead.

### Home Manager: "existing file would be clobbered"

A dotfile already exists where Home Manager wants to write. Back up or move that file,
then run `dr` again.

### Alacritty `Brew bundle failed` / cask disabled

The Homebrew Alacritty cask is disabled (it fails Gatekeeper), so a fresh Brew install of
it fails. Work installs Alacritty through Nix instead, at
`~/Applications/Home Manager Apps/Alacritty.app`.

### Alacritty not in Spotlight

Run `dr`, then open the app once:
```shell
open "$HOME/Applications/Home Manager Apps/Alacritty.app"
```
If macOS asks for App Management access, allow your terminal in
System Settings → Privacy & Security → App Management, then run `dr` again.

### Touch ID for sudo not working (incl. inside tmux)

Both profiles enable Touch ID for sudo, with `pam_reattach` so it also works inside tmux.

```shell
grep -E 'pam_(tid|reattach)' /etc/pam.d/sudo_local   # both lines should be listed
sudo -k && sudo -v                                    # should prompt for Touch ID
```

A Mac mini needs a Magic Keyboard with Touch ID and a fingerprint enrolled in
System Settings.

---

## Work profile notes

**Installs:** Zsh + Powerlevel10k, fzf, bat, btop, tmux, eza, fd, ripgrep, zoxide, delta,
jq, yq, direnv, glab, gh, AWS CLI, e1s, uv, Node.js 22, pnpm, Podman, lazydocker, Alacritty.
Brew: k6, mole, Meslo Nerd Font, AWS Session Manager plugin, Sublime Text.
No language runtimes beyond these; use per-project environments.

**Containers (Podman):**

| Command | Effect |
| --- | --- |
| `pm up` | create/start the Podman machine |
| `pm down` | stop it |
| `pm rootful` / `pm rootless` | restart in that mode (separate image stores) |
| `pm status` | state, mode, socket, API check |

`docker` / `docker-compose` are wrappers for podman, so Makefiles keep working.
`DOCKER_HOST` is set for Testcontainers etc. `podman login` stores credentials in Keychain.

**Personal aliases:** `~/.config/zsh/work.zsh` is created on the first rebuild and never
overwritten after that. `wedit` opens it, `wreload` reloads it.

---

## Repo layout

- `flake.nix`: host list
- `hosts/`: per-Mac settings (username, git identity, ownership flags)
- `lib/mk-host.nix`: builds a host from its host file
- `configuration.nix`, `home.nix`: shared system / user config
- `features/terminal/home.nix`: shell, aliases (including `dr`), CLI tools
- `profiles/personal/`, `profiles/work/`: profile-specific packages

## Testing

```shell
bash scripts/test.sh --eval-only        # syntax + evaluate all hosts
bash scripts/test.sh --build <host>     # build without activating
bash scripts/test.sh --dry-run <host>   # show build plan
bash scripts/setup-hooks.sh             # pre-commit syntax hook
nix flake check --no-build --all-systems
```

GitLab CI (`.gitlab-ci.yml`) runs syntax, `nixpkgs-fmt`, `statix` and evaluation checks.

## References

- https://nixos-and-flakes.thiscute.world/
- https://jorel.dev/NixOS4Noobs/intro.html
- Search packages: https://search.nixos.org/packages · https://www.nixhub.io/ · https://mynixos.com/
- Devbox: https://www.jetify.com/docs/devbox/
- nix-homebrew: https://github.com/zhaofengli/nix-homebrew
- nix-darwin: https://github.com/nix-darwin/nix-darwin
- Home Manager options: https://nix-community.github.io/home-manager/options.xhtml
- Mac sample setup: https://github.com/torgeir/nix-darwin
- GitHub references:
  - https://github.com/ProfessorFlaw/NixDotfiles/blob/main/configuration.nix
  - https://github.com/mcdonc/.nixconfig/blob/master/videos/peruserperhost/script.rst
- YouTube example: https://www.youtube.com/watch?v=e8vzW5Y8Gzg
- Config example: https://sandstorm.de/blog/posts/my-first-steps-with-nix-on-mac-osx-as-homebrew-replacement/
