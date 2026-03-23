{ lib, config, pkgs, ... }:

let
  cfg = config.main-user;
in
{

 options.main-user = {
   enable 
     = lib.mkEnableOption "enable user module";

   isNormalUser = lib.mkOption {
     default = true;
     description = ''
       sets if regular user
     '';
   };

   userName = lib.mkOption {
     default = "username";
     description = ''
       the login username
     '';
     };

   description = lib.mkOption {
     default = "user name";
     description = ''
       typicallythe user's full name
     '';
   };
   
    extraGroups = lib.mkOption {
      default = [ ];
      description = ''
        groups this user should belong to
      '';
    };
  };

 config = lib.mkIf cfg.enable {
  users.users.${cfg.userName} = {
    isNormalUser = cfg.isNormalUser;
    description = cfg.description;
    extraGroups = cfg.extraGroups;
  };
 };

}
