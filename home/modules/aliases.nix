_: {
  # Bash aliases configuration
  home.shellAliases = {
    # Yazi alias
    ya = "yazi_cd";

    # Standard ls aliases
    l = "ls -alh";
    ll = "ls -l";
    ls = "ls --color=tty";

    "hx." = "hx .";
    "da" = "direnv allow";
    "ga." = "git add .";
    "ga" = "git add";
    "gd" = "git -c diff.external=difft diff";
    "gp" = "git push";
    "gpf" = "git push --force";
    "gr" = "git restore";
    "gr." = "git restore .";
    "grs" = "git restore --staged";
    "gs" = "git status";
    "gc" = "git commit";
    "gcm" = "git commit -m";
    "gca" = "git commit --amend";

    "tmux" = "tmux -f ~/.config/tmux/tmux.conf";
    "txa" = ''tmux attach-session -t $(tmux list-sessions -F "#{session_name}" | head -n 1)'';
    "txls" = "tmux list-sessions";
    "txks" = "tmux kill-session -t ";
    "txn" = "tmux new-session -s";
    "txs" = "tmux switch-client -n";
    "txkw" = "tmux kill-window -t ";
    "txlw" = "tmux list-windows";
    "txh" =
      ''tmux new-session -s "$(basename "$(pwd)")_$(echo -n "$(pwd)" | md5sum | cut -d " " -f 1)" "hx ."'';

  };
}
