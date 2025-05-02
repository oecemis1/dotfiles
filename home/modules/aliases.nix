{
  config,
  pkgs,
  lib,
  ...
}: {
  # Bash aliases configuration
  programs.bash.shellAliases = {
    # Yazi alias
    ya = "yazi_cd";
    
    # Standard ls aliases
    l = "ls -alh";
    ll = "ls -l";
    ls = "ls --color=tty";
  };
}
