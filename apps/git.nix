{ host, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        inherit (host.git) email name;
        useConfigOnly = true;
      };
      merge = {
        conflictstyle = "diff3";
      };
      diff = {
        colorMoved = "default";
      };
    };
  };
}
