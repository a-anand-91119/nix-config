{ host, ... }:

{
  # User accounts and home directory
  system.primaryUser = host.username;
  users.users.${host.username} = {
    name = host.username;
    home = host.homeDirectory;
  };

}
