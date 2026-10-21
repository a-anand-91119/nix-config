# macOS configurations

One flake manages two independent host outputs:

| Output | Host settings | Applications |
| --- | --- | --- |
| `Anands-MacBook-Pro--M3-Pro` | [hosts/personal-macbook.nix](hosts/personal-macbook.nix) | Existing personal tools, JDKs, desktop apps and tmux plugins |
| `work-mini` | [hosts/work-mini.nix](hosts/work-mini.nix) | Selected terminal/Git baseline, Alacritty, Meslo Nerd Font, and tmux `sensible` only |

Both use `aarch64-darwin`. The work host is intended for the M5 Mac mini with
24 GB RAM and a 1 TB SSD. Its output name does not rename the macOS computer.

## What the work profile installs

- Shell: Zsh, Powerlevel10k, autosuggestions, fzf-tab and fzf.
- CLI: bat, btop, tmux, eza, coreutils, gawk, Git, fd, zoxide, Delta, curl,
  jq, yq, ripgrep, direnv and nixpkgs-fmt.
- Management/support: Home Manager and mkalias.
- Terminal app: Alacritty through Nix/Home Manager.
- Brew cask: Meslo LG Nerd Font.
- Tmux plugin: `sensible` only.

There are no work Brew formulae. Node, Python, Java, Ruby, Rust, Docker,
Kubernetes, AI apps, extra fonts, session-persistence plugins and package-manager
wrappers are omitted. Normal package dependencies are still installed.
Use project environments or select an additional feature when a project needs a
runtime. Neither profile installs VS Code. Work uses macOS's built-in
`/usr/bin/vi` for `EDITOR` and `VISUAL`; personal retains Helix.

## Separation and ownership

- `lib/mk-host.nix` builds either host and passes its metadata to Darwin and
  Home Manager. Edit username, home/check-out paths, Git identity and ownership
  flags in the host file.
- `configuration.nix` and `home.nix` compose the shared system and user setup.
- `features/terminal/home.nix` owns shared shell behavior and selected CLI tools.
- `profiles/personal/` imports the existing personal package lists, language
  integrations, package-manager policy and optional tmux plugins.
- `profiles/work/` contains the work-only allowlist and editor/app ownership.

Both host files use the same fields and derive home/check-out paths from the
username. Nix, Homebrew and migration ownership flags have the
same meaning for either host. Each file keeps its own identity and profile so the
machines can be edited independently.

User programs and dotfiles are managed by Home Manager. Home Manager installs
the work Alacritty app and writes its settings; Brew owns the font.
The work host does not import the personal `/Applications/Nix Apps`
script, macOS preferences, login-window banner or Touch ID configuration.

Work Brew activation uses `cleanup = "none"`, `upgrade = false` and
`autoUpdate = false`. Both profiles use `cleanup = "none"`, so removing a package
declaration preserves an existing installation and its data. Personal still
updates and upgrades its listed Brew packages during activation. A Nix generation
rollback does not undo arbitrary Brew upgrades or restore removed application data.

## Set up the new Mac

1. Confirm the short username with `id -un` and the home directory with
   `echo "$HOME"`. `hosts/work-mini.nix` currently uses `aanand`,
   `/Users/aanand`, and `~/nix-config`. Change the host file if needed. It uses
   the existing Git name `A Anand` and email `a.anand.91119@gmail.com`, as requested.
   GitHub login/SSH keys are separate from the commit identity.
2. You need administrator access. Install Apple's command-line developer tools
   if not present (`xcode-select --install`). Check whether Homebrew or the
   selected apps are already installed before assigning ownership.
3. Install **one** macOS multi-user Nix distribution using its current
   [official instructions](https://nixos.org/download/), then reopen Terminal.
   The concrete installer commands are under [Nix installation options](#nix-installation-options).
   The default host settings let nix-darwin manage upstream Nix.
   If you choose [Determinate Nix](https://docs.determinate.systems/guides/nix-darwin/),
   set `manageNix = false` in the host file **before** bootstrapping. This also
   leaves daemon settings, garbage collection and optimisation to that installation.
   Do not install a second distribution over an existing one as a repair step.
4. Clone the repository using your available GitLab account and network access:

   ```sh
   git clone https://gitlab.notyouraverage.dev/a.anand.91119/nix-config.git ~/nix-config
   cd ~/nix-config
   ```

   If Git is unavailable, Nix can provide it for the clone without adding it to
   your permanent package list:

   ```sh
   nix --extra-experimental-features 'nix-command flakes' shell nixpkgs#git --command \
     git clone https://gitlab.notyouraverage.dev/a.anand.91119/nix-config.git ~/nix-config
   cd ~/nix-config
   ```

   The existing checkout's SSH remote uses port 8443. Use the appropriate SSH or
   HTTPS transport for the new Mac; do not assume its keys are already registered.
   New Nix module files must be added to Git before a normal `.#host` flake build
   can see them. The test script uses `path:` to include untracked files without
   modifying your index.
5. Review `hosts/work-mini.nix`. For a new Brew installation leave
   `migrateHomebrew = false`. If intentionally handing an existing, self-managed
   Brew installation to nix-homebrew, set it to `true` after reviewing ownership
   and existing taps. Do not migrate a company-managed installation implicitly.
   Set `manageHomebrew = false` to leave Brew/font installation external.
   The work Alacritty app remains managed by Nix/Home Manager.
6. Evaluate and build the work configuration using its **locked** nix-darwin input:
   For a personal installation, replace `work-mini` with
   `Anands-MacBook-Pro--M3-Pro` in both the build and switch commands.

   ```sh
   nix --extra-experimental-features 'nix-command flakes' run \
     --inputs-from . nix-darwin#darwin-rebuild -- build --flake .#work-mini
   ```

   This builds without activating the system. Review any existing Home Manager
   dotfile conflicts before continuing. Back up/migrate those files deliberately;
   do not force-overwrite registry credentials or application settings.
7. Apply the work profile only when ready:

   ```sh
   sudo nix --extra-experimental-features 'nix-command flakes' run \
     --inputs-from . nix-darwin#darwin-rebuild -- switch --flake .#work-mini
   ```

8. Open a new terminal. Check `git config --get user.email`, `alacritty --version`,
   `tmux -V`, prompt/icons, and Finder/Spotlight app visibility. Alacritty starts
   tmux, which starts Zsh. Set up new GitLab/GitHub authentication separately;
   never copy personal credential directories wholesale as an installation step.

## Nix installation options

For the default `manageNix = true` setup, install upstream multi-user Nix:

```sh
curl -L https://nixos.org/nix/install | sh -s -- --daemon
```

This is the [official multi-user installer](https://nix.dev/manual/nix/latest/installation/installing-binary.html#multi-user-installation).
Run it from your normal account and follow its sudo prompts.

Alternatively, install Determinate Nix using its macOS installer or shell installer:

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Set `manageNix = false` in the selected host file before the first rebuild.
See [Determinate's installation documentation](https://docs.determinate.systems/)
and [nix-darwin integration guide](https://docs.determinate.systems/guides/nix-darwin/).
Choose one installer for a new Mac; repairing or migrating an existing
installation should follow that installer's instructions.

Reopen Terminal after installation and check:

```sh
command -v nix
nix --version
```

If the installer has written its daemon shell setup but this terminal has not
loaded it yet:

```sh
if [ -r /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi
```

For an installation created by Determinate Nix Installer, its uninstaller is:

```sh
sudo /nix/nix-installer uninstall
```

Use this only when intentionally removing that installation, following its
installer receipt and documentation. It removes Nix; it is not a rebuild step.

## Rebuild, validate and update

After installation, `dr` targets the current host's configured checkout and output.
The first activation selects the profile; opening a new terminal loads its alias:

```sh
alias dr
dr
```

The same alias selects `work-mini` on the work Mac and
`Anands-MacBook-Pro--M3-Pro` on the personal Mac. It applies the local checkout;
run `git pull` separately when you want to retrieve remote changes.
Explicit commands are also available:

```sh
# Validate syntax and evaluate both outputs (no build or activation).
bash scripts/test.sh --eval-only

# Actually build both systems on an Apple Silicon Mac, without activation.
bash scripts/test.sh --build

# Build only the selected host; both hosts are still checked for evaluation errors.
bash scripts/test.sh --build work-mini

# Show a build plan without building it.
bash scripts/test.sh --dry-run work-mini

# Apply a previously reviewed work change.
sudo darwin-rebuild switch --flake ~/nix-config#work-mini

# Existing personal target, kept separate.
sudo darwin-rebuild switch --flake ~/nix-config#Anands-MacBook-Pro--M3-Pro

# Optional contributor hook and its regression checks.
bash scripts/setup-hooks.sh
python3 tests/test-validation.py

# Parse one Nix file or evaluate the complete flake manually.
nix-instantiate --parse path/to/file.nix
nix flake check --no-build --all-systems
```

`nix flake check --no-build --all-systems` validates both system derivations
and the selected-work-profile assertions. `--build` also runs the selection check.
Linux CI checks syntax, formatting, statix, evaluation and validation-script
regressions; it does not claim to have built or activated a macOS system.
Building a Nix system does not run Brew: cask downloads, installation and
existing-file migrations are exercised only when you activate on the target Mac.

Keep the existing `flake.lock` for the first migration. Later, intentionally run
`nix flake update`, review the lockfile diff, and validate/build both profiles
before activation. Compatibility values (`system.stateVersion = 5` and
`home.stateVersion = "23.05"`) are not package versions and should not be bumped
just because dependencies were updated. Old unused inputs are retained in the
lockfile during this split rather than combining migration with a broad update.

## Upgrading Nix on macOS

When `manageNix = true`, nix-darwin manages the Nix package and daemon from the
locked nixpkgs input. Upgrade through the same reviewed configuration workflow:

```sh
cd ~/nix-config
nix flake update
bash scripts/test.sh --build
dr
nix --version
```

Review the lockfile diff before `dr`. A plain rebuild uses the existing lock;
updating the inputs and applying them are separate steps.

When `manageNix = false`, the installer or external administrator owns daemon
upgrades. Use Determinate's upgrade process for Determinate Nix. For a standalone
upstream macOS multi-user installation that is not managed by nix-darwin, the
[upstream upgrade procedure](https://nix.dev/manual/nix/latest/installation/upgrading.html)
is:

```sh
sudo nix-env --install --file '<nixpkgs>' --attr nix cacert -I nixpkgs=channel:nixpkgs-unstable
sudo launchctl remove org.nixos.nix-daemon
sudo launchctl load /Library/LaunchDaemons/org.nixos.nix-daemon.plist
```

These standalone commands use an imperative Nix profile and channel. Use the
flake workflow above for this repository's default nix-darwin-managed setup.

## Troubleshooting

### SSL / CA certificate errors

The old setup could leave a stale link to
`/etc/static/ssl/certs/ca-certificates.crt`. Inspect the link and available Nix
bundle first:

```sh
ls -l /etc/ssl/certs/ca-certificates.crt
readlink /etc/ssl/certs/ca-certificates.crt
ls -l /nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt
```

For that specific historical problem, the following repair only replaces the
known dangling symlink when the replacement bundle is readable:

```sh
nix_ca_link=/etc/ssl/certs/ca-certificates.crt
nix_ca_bundle=/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt
if [ -L "$nix_ca_link" ] && [ ! -e "$nix_ca_link" ] &&
   [ "$(readlink "$nix_ca_link")" = /etc/static/ssl/certs/ca-certificates.crt ] &&
   [ -r "$nix_ca_bundle" ]; then
  sudo ln -sfn "$nix_ca_bundle" "$nix_ca_link"
fi
```

The original report is [SSL CA cert error on macOS](https://discourse.nixos.org/t/ssl-ca-cert-error-on-macos/31171/3).
For a readable bundle or a corporate TLS proxy, diagnose the trust configuration
instead of replacing links. Nix supports `NIX_SSL_CERT_FILE` for the client and
`ssl-cert-file` for the daemon; see the
[certificate configuration documentation](https://nix.dev/manual/nix/latest/installation/env-variables.html).
Use the company's complete trusted CA bundle. With `manageNix = true`, daemon
settings belong in `nix.settings` in `modules/nix-settings.nix`; with external
Nix management, follow that installation's configuration process.

### Zsh: `compinit: insecure directories`

Run this in an interactive Zsh shell to list affected completion paths:

```sh
autoload -Uz compaudit
compaudit
```

Inspect the ownership and permissions of the reported paths. For each confirmed
directory you own, remove group/other write access using its exact path:

```sh
ls -ld /path/reported/by/compaudit
chmod go-w /path/reported/by/compaudit
compaudit
```

Use sudo only where the intended owner and required permissions justify it.
For Brew paths, inspect `$(brew --prefix)/share` and its reported children;
avoid recursively changing the entire tree or modifying the Nix store.
If no paths are reported, repeat `compaudit` in the shell that displays the
warning and inspect its `$fpath` and startup files. Home Manager initializes
completion for work; Oh My Zsh does so for personal. Do not hide the issue by
disabling the security check. See [Oh My Zsh troubleshooting](https://github.com/ohmyzsh/ohmyzsh/wiki/Troubleshooting).

### Alacritty cask disabled / `Brew bundle failed`

The pinned Homebrew cask contains a disable date of `2026-09-01` because its
download does not pass Homebrew's macOS Gatekeeper requirements. After that date,
a fresh Brew installation fails even with an unchanged `flake.lock`. See the
[cask definition](https://github.com/Homebrew/homebrew-cask/blob/master/Casks/a/alacritty.rb).

The work profile installs Alacritty through Nix/Home Manager instead. Get the
checkout containing this fix, then repeat the work build and switch commands
from the setup steps. If the first activation failed, use those explicit commands
until `dr` is available. The app appears under
`~/Applications/Home Manager Apps/Alacritty.app`; its theme, font and tmux setup
are unchanged. The Meslo font remains managed by Brew.

An existing Brew Alacritty installation can keep running while a new installation
is blocked. The personal profile retains its existing app ownership; reinstalling
its Brew cask can encounter the same error. Nix builds do not run Brew, so a
successful Nix build alone cannot establish that every cask is installable.

The macOS prerelease warning is a separate Homebrew support diagnostic. It does
not explain the date-based cask disablement, and a newer macOS/Homebrew support
status does not by itself re-enable a disabled cask.

### Homebrew untap permission errors

For an error such as
`Permission denied @ apply2files - /opt/homebrew/Library/Taps/homebrew/homebrew-bundle`,
inspect the tap tree and its links:

```sh
brew --prefix
ls -ld /opt/homebrew/Library/Taps /opt/homebrew/Library/Taps/homebrew
ls -ld /opt/homebrew/Library/Taps/homebrew/homebrew-bundle
readlink /opt/homebrew/Library/Taps
readlink /opt/homebrew/Library/Taps/homebrew/homebrew-bundle
```

This configuration sets `mutableTaps = false`: declared taps live in the Nix
store. Reconcile `nix-homebrew.taps` in `lib/mk-host.nix` and rebuild; the builder
keeps `homebrew.taps` synchronized. Personal declares the bundle tap; work does
not. For an existing self-managed Brew installation, review the host's
`migrateHomebrew` setting before adopting it.

The old manual unlink workaround applies only to an obsolete tap link in a
legacy, unmanaged tap tree after confirming it is no longer declared. In that
case, unlink that individual symlink and retry the rebuild:

```sh
if [ ! -L /opt/homebrew/Library/Taps ] &&
   [ ! -L /opt/homebrew/Library/Taps/homebrew ] &&
   [ -L /opt/homebrew/Library/Taps/homebrew/homebrew-bundle ]; then
  sudo unlink /opt/homebrew/Library/Taps/homebrew/homebrew-bundle
fi
```

For a current Nix-managed tree, use the declarative fix instead of changing
permissions or deleting store contents. See [nix-homebrew tap management](https://github.com/zhaofengli/nix-homebrew#declarative-tap-management).

### Existing dotfiles or a missing rebuild alias

If Home Manager reports an existing file would be overwritten, inspect and back
up that particular file before retrying activation. Migrate credentials and
application settings deliberately. Open a new terminal after activation and run
`alias dr`; if it is missing, use the explicit host-specific rebuild command
above and check that Zsh loaded the generated Home Manager configuration.

### Uninstalling and credentials

`uninstall-nix-macos.sh` is a separate destructive maintenance script, not a
bootstrap step. Prefer the selected installer's documented uninstaller; review
backups, installation ownership and APFS target detection before any removal.
Keep credentials out of tracked Nix strings and the Nix store. Use the intended
credential manager or environment-based work authentication. Ignore rules are
not a security boundary.

## References

- [nix-darwin](https://github.com/nix-darwin/nix-darwin)
- [Home Manager manual](https://nix-community.github.io/home-manager/) and [option reference](https://nix-community.github.io/home-manager/options.xhtml)
- [nix-homebrew](https://github.com/zhaofengli/nix-homebrew)
- [Nix package search](https://search.nixos.org/packages), [NixHub](https://www.nixhub.io/) and [MyNixOS](https://mynixos.com/)
- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/)
- [NixOS4Noobs](https://jorel.dev/NixOS4Noobs/intro.html)
- [Devbox documentation](https://www.jetify.com/docs/devbox/)
- [torgeir's Mac configuration](https://github.com/torgeir/nix-darwin)
- [ProfessorFlaw's configuration example](https://github.com/ProfessorFlaw/NixDotfiles/blob/main/configuration.nix)
- [mcdonc's per-user/per-host walkthrough](https://github.com/mcdonc/.nixconfig/blob/master/videos/peruserperhost/script.rst)
- [Video example](https://www.youtube.com/watch?v=e8vzW5Y8Gzg)
- [First steps with Nix on macOS](https://sandstorm.de/blog/posts/my-first-steps-with-nix-on-mac-osx-as-homebrew-replacement/)
