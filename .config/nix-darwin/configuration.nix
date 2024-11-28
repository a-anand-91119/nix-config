{ pkgs, config, ... }:

{
  imports = builtins.attrValues (builtins.readDir ./modules);
}