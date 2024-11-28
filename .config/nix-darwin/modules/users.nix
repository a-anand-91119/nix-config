{ pkgs, config, ... }:

{
  # User accounts and home directory
  users.users.aanand = {
      name = "aanand";
      home = "/Users/aanand";
  };

}
