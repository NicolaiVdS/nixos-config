{
  config,
  inputs,
  lib,
  ...
}:
{
  options.flake.modules.nixos = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.deferredModule;
    default = { };
  };

  config.flake.nixosConfigurations =
    let
      hosts = config.flake.modules.nixos.hosts or { };
    in
    lib.mapAttrs (
      hostname: hostModule:
      inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          hostModule
          inputs.disko.nixosModules.disko
          inputs.home-manager.nixosModules.home-manager
          { networking.hostName = lib.mkDefault hostname; }
        ];
      }
    ) hosts;
}
