{ self }:
{ config, lib, pkgs, ... }:

let
  cfg = config.programs.citron-nextendo;
  system = pkgs.stdenv.hostPlatform.system;
in
{
  options.programs.citron-nextendo = {
    enable = lib.mkEnableOption "Citron Nextendo";

    package = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${system}.default;
      defaultText = lib.literalExpression "citron-nextendo.packages.${pkgs.system}.default";
      description = "Citron Nextendo package to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.elem system [ "x86_64-linux" "aarch64-linux" ];
        message = "programs.citron-nextendo only supports x86_64-linux and aarch64-linux.";
      }
    ];

    programs.fuse.enable = true;
    environment.systemPackages = [ cfg.package ];
    services.udev.packages = [ cfg.package ];
  };
}
