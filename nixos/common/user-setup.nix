{
  lib,
  pkgs,
  inputs,
  username ? throw "You must define a username",
  uid ? 1000,
  extraGroups ? [ ],
  useHomeManager ? true,
  homeManagerImports ? [ ],
  homeManagerArgs ? { },
  ...
}:

let
  commonGroups = [
    "networkmanager"
    "wheel"
    "audio"
    "video"
    "input"
    "uinput"
    "libvirtd"
    "docker"
  ];
  allGroups = lib.unique (commonGroups ++ extraGroups);
in
{
  users.users.${username} = {
    isNormalUser = true;
    inherit uid;
    extraGroups = allGroups;
    linger = true;
  };

  home-manager = lib.mkIf useHomeManager {
    extraSpecialArgs = {
      inherit inputs pkgs;
    } // homeManagerArgs;
    backupFileExtension = "bak";
    users.${username} = {
      imports = homeManagerImports;
    };
  };
}
