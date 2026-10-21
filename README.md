# macOS configurations

One flake manages two independent host outputs:

| Output | Host settings | Applications |
| --- | --- | --- |
| `Anands-MacBook-Pro--M3-Pro` | [hosts/personal-macbook.nix](hosts/personal-macbook.nix) | Existing personal tools, JDKs, desktop apps and tmux plugins |
| `work-mini` | [hosts/work-mini.nix](hosts/work-mini.nix) | Selected terminal/Git baseline, Alacritty, Meslo Nerd Font, VS Code, and tmux `sensible` only |

Both use `aarch64-darwin`. The work host is intended for the M5 Mac mini with
24 GB RAM and a 1 TB SSD. Its output name does not rename the macOS computer.

## What the work profile installs

- Shell: Zsh, Powerlevel10k, autosuggestions, fzf-tab and fzf.
- CLI: bat, btop, tmux, eza, coreutils, gawk, Git, fd, zoxide, Delta, curl,
  jq, yq, ripgrep, direnv and nixpkgs-fmt.
- Management/support: Home Manager and mkalias.
- Brew casks: Alacritty, Meslo LG Nerd Font and Visual Studio Code.
- Tmux plugin: `sensible` only.

There are no work Brew formulae. Node, Python, Java, Ruby, Rust, Docker,
Kubernetes, AI apps, extra fonts, session-persistence plugins and package-manager
wrappers are omitted. Normal package dependencies are still installed.
Use project environments or select an additional feature when a project needs a
runtime; VS Code alone does not provision it.

## Separation and ownership

- `lib/mk-host.nix` builds either host and passes its metadata to Darwin and
  Home Manager. Edit username, home/check-out paths, Git identity and ownership
  flags in the host file.
- `configuration.nix` and `home.nix` compose the shared system and user setup.
- `features/terminal/home.nix` owns shared shell behavior and selected CLI tools.
- `profiles/personal/` imports the existing personal package lists, language
  integrations, package-manager policy and optional tmux plugins.
- `profiles/work/` contains the work-only allowlist and editor/app ownership.

User programs and dotfiles are managed by Home Manager. Brew owns the work
Alacritty app and font; Home Manager writes Alacritty's settings without installing
a second copy. The work host does not import the personal `/Applications/Nix Apps`
script, macOS preferences, login-window banner or Touch ID configuration.

Work Brew activation uses `cleanup = "none"`, `upgrade = false` and
`autoUpdate = false`, so unlisted work software is preserved. The personal host
retains its existing Brew cleanup/upgrade policy. A Nix generation rollback does
not undo arbitrary Brew upgrades or restore removed application data.

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

   The existing checkout's SSH remote uses port 8443. Use the appropriate SSH or
   HTTPS transport for the new Mac; do not assume its keys are already registered.
   New Nix module files must be added to Git before a normal `.#host` flake build
   can see them. The test script uses `path:` to include untracked files without
   modifying your index.
5. Review `hosts/work-mini.nix`. For a new Brew installation leave
   `migrateHomebrew = false`. If intentionally handing an existing, self-managed
   Brew installation to nix-homebrew, set it to `true` after reviewing ownership
   and existing taps. Do not migrate a company-managed installation implicitly.
   Set `manageHomebrew = false` to leave Brew/app installation external, or
   `vscodeManagedExternally = true` if only VS Code has another owner.
6. Evaluate and build the work configuration using its **locked** nix-darwin input:

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

8. Open a new terminal. Check `git config --get user.email`, `code --version`,
   `tmux -V`, prompt/icons, and Finder/Spotlight app visibility. Alacritty starts
   tmux, which starts Zsh. Set up new GitLab/GitHub authentication separately;
   never copy personal credential directories wholesale as an installation step.

## Rebuild, validate and update

After installation, `dr` targets the current host's configured checkout and output.
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
```

`nix flake check --no-build --all-systems` validates both system derivations and
the selected-work-profile assertions. `--build` also runs the work-selection check.
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

## Troubleshooting boundaries

- For shell permission warnings, run `compaudit` and fix the specific affected
  ownership/permission issue. Completion security checks are not disabled globally.
- For TLS or corporate certificate problems, diagnose the selected Nix installer's
  and company's trust configuration; do not delete system certificate symlinks as
  a routine bootstrap step.
- For Brew ownership or tap errors, inspect the existing installation and declared
  taps before changing permissions or deleting links. Declarative taps cannot be
  extended with a permanent imperative `brew tap` when mutable taps are disabled.
- `uninstall-nix-macos.sh` is a separate destructive maintenance script, not a
  bootstrap step. Prefer the selected installer's documented uninstaller; review
  backups, installation ownership and APFS target detection before any removal.
- Keep credentials out of tracked Nix strings and the Nix store. Use the intended
  credential manager or environment-based work authentication. Ignore rules are
  not a security boundary.

References: [nix-darwin](https://github.com/nix-darwin/nix-darwin),
[Home Manager](https://nix-community.github.io/home-manager/),
[nix-homebrew](https://github.com/zhaofengli/nix-homebrew), and
[Nix packages](https://search.nixos.org/packages).
