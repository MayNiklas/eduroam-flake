{ self, unis }:
{ config, lib, pkgs, utils, ... }:

let
  cfg = config.networking.eduroam;
  passwordEnvFile = "/run/eduroam/password.env";
  extracted = self.packages.${pkgs.stdenv.hostPlatform.system}."eduroam-settings-${cfg.university}";
  # import from derivation: the settings are read from the downloaded installer
  settings = lib.importJSON "${extracted}/settings.json";
  identity =
    if lib.hasInfix "@" cfg.username || settings.userRealm == ""
    then cfg.username
    else "${cfg.username}@${settings.userRealm}";

  # mirrors the connection the installer adds via D-Bus
  mkProfile = ssid: {
    connection = {
      id = ssid;
      type = "wifi";
    };
    wifi = {
      inherit ssid;
      mode = "infrastructure";
    };
    wifi-security.key-mgmt = "wpa-eap";
    "802-1x" = {
      eap = lib.toLower settings.eapOuter;
      phase2-auth = lib.toLower settings.eapInner;
      inherit identity;
      anonymous-identity = lib.mkIf (settings.anonymousIdentity != "") settings.anonymousIdentity;
      ca-cert = "${extracted}/ca.pem";
      domain-match = settings.serverDomain;
      # system-owned: NetworkManager would ask session agents (e.g. the GNOME dialog) first for agent-owned secrets
      password-flags = if cfg.passwordFile != null then 0 else 1;
      password = lib.mkIf (cfg.passwordFile != null) "$EDUROAM_PASSWORD";
    };
    ipv4.method = "auto";
    ipv6.method = "auto";
  };
in
{
  options.networking.eduroam = {
    enable = lib.mkEnableOption "eduroam in NetworkManager";
    university = lib.mkOption {
      type = lib.types.enum (map (uni: uni.name) unis);
      description = "Name of the university in universities.nix.";
    };
    username = lib.mkOption {
      type = lib.types.str;
      description = "Username; the university's realm is appended if it contains no `@`.";
    };
    passwordFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/run/secrets/eduroam";
      description = ''
        File containing only the password, e.g. a sops secret; a trailing newline is ignored.
        Use a path outside of the Nix store, which is world-readable.
        After changing its content, restart `NetworkManager-ensure-profiles.service`.
        Without it, NetworkManager asks once and keeps the password in the keyring.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.elem settings.eapOuter [ "PEAP" "TTLS" ];
        message = "networking.eduroam: ${cfg.university} uses ${settings.eapOuter}, only PEAP and TTLS are supported";
      }
      {
        assertion = config.networking.networkmanager.enable;
        message = "networking.eduroam: requires `networking.networkmanager.enable = true;`";
      }
      {
        assertion = cfg.passwordFile == null || (lib.hasPrefix "/" cfg.passwordFile && !lib.hasPrefix builtins.storeDir cfg.passwordFile);
        message = "networking.eduroam: passwordFile must be an absolute path outside of the world-readable Nix store, e.g. /run/secrets/eduroam, got ${cfg.passwordFile}";
      }
    ];
    systemd.services.eduroam-password = lib.mkIf (cfg.passwordFile != null) {
      description = "Provide the eduroam password to NetworkManager-ensure-profiles";
      requiredBy = [ "NetworkManager-ensure-profiles.service" ];
      before = [ "NetworkManager-ensure-profiles.service" ];
      serviceConfig = {
        # runs again on every start of NetworkManager-ensure-profiles, the file outlives the process
        Type = "oneshot";
        UMask = "0077";
        RuntimeDirectory = "eduroam";
        RuntimeDirectoryPreserve = true;
        ExecStart = utils.escapeSystemdExecArgs [ pkgs.python3.interpreter "${./write-password-env.py}" cfg.passwordFile passwordEnvFile ];
      };
    };
    networking.networkmanager.ensureProfiles = {
      environmentFiles = lib.optional (cfg.passwordFile != null) passwordEnvFile;
      profiles = lib.genAttrs settings.ssids mkProfile;
    };
  };
}
