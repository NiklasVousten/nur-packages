{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.crab-hole;
in
{
  options = {
    services.crab-hole = { 
      enable = mkEnableOption "Crab-hole Service";

      user = mkOption {
        type = types.str;
        default = "crab-hole";
        description = "User account under which crab-hole runs.";
      };

      group = mkOption {
        type = types.str;
        default = "crab-hole";
        description = "Group account under which crab-hole runs.";
      };

      workDir = mkOption {
        type = types.str;
        default = "/var/lib/crab-hole";
        description = "Crab-holes data directory.";
      };

      configFile = mkOption {
        type = types.path;
        description = "The config file of crab-hole";
      };

      blockListFiles = mkOption {
        type = types.listOf types.path;
        default = [];
        description = "Path of the blocklists";
      };

      allowListFiles = mkOption {
        type = types.listOf types.path;
        default = [];
        description = "Path of the allowlists";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.crab-hole = {
      wantedBy = [ "multi-user.target" ]; 
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      description = "Start the crab-hole dns server";
      environment = {
        CRAB_HOLE_DIR = cfg.workDir;
      };
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.workDir;

        ExecStart = ''${pkgs.nur.repos.NiklasVousten.crab-hole}/bin/crab-hole'';

        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";

        Restart = "on-failure";
        RestartSec = 1;
      };
      
      preStart = ''
        cp -f '${cfg.configFile}' '${cfg.workDir}/config.toml'
        ${builtins.concatStringsSep "\n" (map (file: "cp -f '${file}' '${cfg.workDir}/${lib.lists.last (builtins.split "/" (builtins.toString file))}'") cfg.blockListFiles)}
        ${builtins.concatStringsSep "\n" (map (file: "cp -f '${file}' '${cfg.workDir}/${lib.lists.last (builtins.split "/" (builtins.toString file))}'") cfg.allowListFiles)}
      '';
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.workDir}' 0750 ${cfg.user} ${cfg.group} - -"
    ];

    # Adding crab-hole user and group
    users.users = optionalAttrs (cfg.user == "crab-hole") {
      crab-hole = {
        description = "Crab-hole service";
        home = cfg.workDir;
        group = cfg.group;
        isSystemUser = true;
      };
    };

    users.groups = optionalAttrs (cfg.group == "crab-hole") {
      crab-hole = {};
    };
 
    environment.systemPackages = [
      crab-hole
    ];
  };
}

