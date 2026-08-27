# Config lives in .config/nvim (linked via xdg-configs.nix); nvim-lspconfig
# only supplies the server definitions that init.lua's executable-gated
# vim.lsp.enable loop reads. EDITOR stays hx (env-base.nix).
{ ... }:
{
  flake.modules.homeManager.cli =
    { pkgs, ... }:
    {
      programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        plugins = [ pkgs.vimPlugins.nvim-lspconfig ];
      };
    };
}
