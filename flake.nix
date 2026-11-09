{
  description = "Install eduroam on NixOS systems";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, ... } @ inputs:
    with inputs; let
      supportedSystems = [ "aarch64-linux" "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system:
        import nixpkgs {
          inherit system;
          overlays = [ ];
        });
      unis = import ./universities.nix;
      fetchInstaller = pkgs: uni:
        pkgs.fetchurl {
          name = uni.name;
          url = "https://cat.eduroam.org/user/API.php?action=downloadInstaller&lang=en&profile=${builtins.toString uni.id}&device=linux&generatedfor=user&openroaming=0";
          sha256 = uni.hash or "";
        };
    in
    {
      nixosModules.default = import ./module.nix { inherit self unis; };
      checks = forAllSystems (system: {
        check-hashes =
          let
            pkgs = nixpkgsFor.${system};
            downloadedFiles = map (fetchInstaller pkgs) unis;
          in
          pkgs.stdenv.mkDerivation {
            name = "download-files";
            src = ./.;
            buildPhase = ''
              mkdir -p $out
              ${nixpkgs.lib.concatMapStringsSep "\n" (file: ''
                  cp ${file} $out/
                '')
                downloadedFiles}
            '';
            installPhase = "true";
          };
        write-password-env =
          let
            pkgs = nixpkgsFor.${system};
          in
          pkgs.runCommand "write-password-env-test"
            {
              nativeBuildInputs = [ (pkgs.python3.withPackages (p: [ p.pygobject3 ])) pkgs.gobject-introspection ];
              buildInputs = [ pkgs.glib ];
            } ''
            python3 ${./.}/write-password-env-test.py
            touch $out
          '';
      });
      formatter = forAllSystems (system: nixpkgsFor.${system}.nixpkgs-fmt);
      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
          python-with-dbus = pkgs.python3.withPackages (p: with p; [ dbus-python ]);
        in
        builtins.listToAttrs
          (builtins.map
            (item: {
              name = "install-eduroam-${item.name}";
              value = pkgs.writeShellScriptBin "install-eduroam-${item.name}" ''
                ${python-with-dbus}/bin/python ${fetchInstaller pkgs item}
              '';
            })
            unis)
        // builtins.listToAttrs (
          builtins.map
            (item: {
              name = "eduroam-settings-${item.name}";
              value = pkgs.runCommand "eduroam-settings-${item.name}" { } ''
                ${pkgs.python3}/bin/python3 ${./extract-settings.py} ${fetchInstaller pkgs item} $out
              '';
            })
            unis
        )
        // {
          # nix run .#list-eduroam-entityIDs
          list-eduroam-entityIDs =
            pkgs.writeShellScriptBin "list-eduroam-entityIDs"
              "${pkgs.curl}/bin/curl 'https://cat.eduroam.org/user/API.php?action=listAllIdentityProviders&api' | ${pkgs.jq}/bin/jq";
        });
    };
}
