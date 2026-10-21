{ pkgs, ... }:

{
  environment = {
    # Personal extras only. Shared user tools are owned by Home Manager.
    systemPackages = with pkgs; [
      mkalias
      stow
      mas
      bc
      nowplaying-cli
      meslo-lg
      zsh-you-should-use
      pam-reattach
      nerd-fonts.fira-code
      lazydocker # Docker TUI
      htop # Interactive process viewer
      jetbrains-mono # JetBrains Mono font
      fzf-git-sh # Bash and zsh key bindings for Git objects, powered by fzf
      asciinema # Terminal session recorder
      yazi # Terminal file manager
      jless # Command-line pager for JSON data
      xh # Friendly and fast tool for sending HTTP requests
      kondo # Clean unneeded files from software projects
      mprocs # Run multiple commands in parallel
      pre-commit # Pre-commit for development
      ansible-lint # Best practices checker for Ansible
      dust # Like du but more intuitive
      devenv # for mananging dev environments
      devbox # Instant, easy, predictable shells and containers
      bun
      uv
      fnm
      julia
    ];
  };



}
