{ self, ... }:
{
  flake.modules.homeManager.cli =
    { ... }:
    {
      home.file = {
        ".local/bin" = {
          source = "${self}/.local/bin";
          recursive = true;
          executable = true;
        };
        ".local/docker-scripts" = {
          source = "${self}/.local/docker-scripts";
          recursive = true;
          executable = true;
        };
      };
    };
}
