{ lib, pkgs, ... }:
{
  # Personal-only integrations. The work profile never imports this module.
  programs.zsh = {
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      # Powerlevel10k is loaded once by the shared terminal module.
      theme = "";
      plugins = [ "git" "sublime" ];
    };
    shellAliases = {
      gpcs = "git push -o ci.skip";
      k = "kubectl";
      d = "docker";
      cc = "claude";
      ccd = "claude --dangerously-skip-permissions";
      cx = "codex";
      cxd = "codex --yolo";
      ccx = "ANTHROPIC_BASE_URL=http://127.0.0.1:8317 ANTHROPIC_AUTH_TOKEN=local-claude-code-bridge CLAUDE_CODE_SUBAGENT_MODEL=gpt-5.6-sol CLAUDE_CODE_ALWAYS_ENABLE_EFFORT=1 CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY=3 ENABLE_TOOL_SEARCH=false claude --model gpt-5.6-sol";
      ccdx = "ANTHROPIC_BASE_URL=http://127.0.0.1:8317 ANTHROPIC_AUTH_TOKEN=local-claude-code-bridge CLAUDE_CODE_SUBAGENT_MODEL=gpt-5.6-sol CLAUDE_CODE_ALWAYS_ENABLE_EFFORT=1 CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY=3 ENABLE_TOOL_SEARCH=false claude --dangerously-skip-permissions --model gpt-5.6-sol";
      oc = "opencode";
      gi = "gemini";
      ccu = "npx ccusage@latest";
      ccum = "npx ccusage@latest monthly";
      python = "python3";
      pip = "pip3";
      # These interactive-only wrappers do not affect scripts/Makefiles.
      npm = "sfw npm";
      pnpm = "sfw pnpm";
      yarn = "sfw yarn";
      npx = "sfw npx";
      uv = "sfw uv";
      cargo = "sfw cargo";
      pip3 = "sfw pip3";
    };
    initContent = lib.mkOrder 1100 ''
      source ${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use/you-should-use.plugin.zsh
      source ${pkgs.fzf-git-sh}/share/fzf-git-sh/fzf-git.sh
      export YSU_MESSAGE_POSITION="after"

      export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
      export PATH="/opt/homebrew/lib/ruby/gems/3.4.0/bin:$PATH"
      export PATH="/Library/Frameworks/Python.framework/Versions/Current/bin:$PATH"
      export PATH="$HOME/Library/Python/3.14/bin:$PATH"
      export PATH="$HOME/.cargo/bin:$PATH"
      if command -v fnm >/dev/null 2>&1; then
        eval "$(fnm env --use-on-cd --shell zsh)"
      fi
      if command -v jenv >/dev/null 2>&1; then
        export PATH="$HOME/.jenv/bin:$PATH"
        eval "$(jenv init - --no-rehash)"
      fi
      if command -v rbenv >/dev/null 2>&1; then
        export PATH="$HOME/.rbenv/shims:$PATH"
        eval "$(rbenv init -)"
      fi
      if [ -f "$HOME/Installs/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/Installs/google-cloud-sdk/path.zsh.inc"; fi
      if [ -f "$HOME/Installs/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/Installs/google-cloud-sdk/completion.zsh.inc"; fi
      export LANG=en_US.UTF-8
      export PATH="$HOME/.opencode/bin:$PATH"
    '';
  };
}
