{
  description = "Install eduroam on NixOS systems";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, ... }@inputs:
    with inputs;
    let
      supportedSystems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
          overlays = [ ];
        }
      );
      unis = import ./universities.nix;
    in
    {
      formatter = forAllSystems (system: nixpkgsFor.${system}.nixpkgs-fmt);
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
          python-with-dbus = pkgs.python3.withPackages (p: with p; [ dbus-python ]);
        in
        builtins.listToAttrs (
          builtins.map (item: {
            name = "install-eduroam-${item.name}";
            value =
              (
                {
                  name,
                  id,
                  hash ? "",
                }:
                let
                  script = pkgs.fetchurl {
                    url = "https://cat.eduroam.org/user/API.php?action=downloadInstaller&lang=en&profile=${builtins.toString id}&device=linux&generatedfor=user&openroaming=0";
                    sha256 = hash;
                  };
                in
                pkgs.writeShellScriptBin "install-eduroam-${name}" ''
                  ${python-with-dbus}/bin/python ${script}
                ''
              )
                item;
          }) unis
        )
        // {
          # nix run .#list-eduroam-entityIDs
          list-eduroam-entityIDs = pkgs.writeShellScriptBin "list-eduroam-entityIDs" "${pkgs.curl}/bin/curl 'https://cat.eduroam.org/user/API.php?action=listAllIdentityProviders&api' | ${pkgs.jq}/bin/jq";
        }
      );
    };
}
