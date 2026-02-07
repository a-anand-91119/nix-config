{ pkgs, ... }:
{
  # Core brews for all machines
  homebrew = {
    brews = [
      "gitlab-ci-local"
      "pre-commit"
    ];
  };
}
