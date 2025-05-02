{
  config,
  pkgs,
  lib,
  ...
}: {
  # Bash environment variables and functions
  programs.bash.initExtra = ''
    export EDITOR=hx
     
  '';
}
