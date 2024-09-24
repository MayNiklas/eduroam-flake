{
  description = "Install eduroam on NixOS systems";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, ... } @ inputs:
    with inputs; let
      supportedSystems = [ "aarch64-linux" "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ ]; });
      unis = [
        { name = "bonn"; id = 5133; hash = "sha256-uPVriEsQAkjibFm0E2xXtXyD2UVddjPMv2gQfRgKIao="; }
        { name = "koeln"; id = 5133; hash = "sha256-uPVriEsQAkjibFm0E2xXtXyD2UVddjPMv2gQfRgKIao="; }
        { name = "leipzig"; id = 5674; hash = "sha256-Clybdol+M5yRYBDxst+14ffThQ/VDYaYeUo6FYyGMpg="; }
        { name = "lund"; id = 1338; hash = "sha256-8pEpF8YC8VZC76fWio6vtupkYEZTeh/f46pyakbVdF0="; }
        { name = "saarland"; id = 10315; hash = "sha256-JPR4qeU4TXkaxeDhnXN+DJ8h3Sz5K8b+FNm3UhPoo1I="; }
        { name = "siegen"; id = 5356; hash = "sha256-fyUno1PytodSyV/fMKqdfAGHZxa3C3m2Nfeskkaotnk="; }
      ];
    in
    {
      formatter = forAllSystems (system: nixpkgsFor.${system}.nixpkgs-fmt);
      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
          python-with-dbus = pkgs.python3.withPackages (p: with p; [ dbus-python ]);
          mkScript = { name, id, hash ? "", }:
            let
              script = pkgs.fetchurl {
                url = "https://cat.eduroam.org/user/API.php?action=downloadInstaller&lang=en&profile=${builtins.toString id}&device=linux&generatedfor=user&openroaming=0";
                sha256 = hash;
              };
            in
            pkgs.writeShellScriptBin "install-eduroam-${name}" ''
              ${python-with-dbus}/bin/python ${script}
            '';
        in
        builtins.listToAttrs
          (builtins.map
            (item: {
              name = "install-eduroam-${item.name}";
              value = mkScript item;
            })
            unis)
        //
        {
          # nix run .#list-eduroam-entityIDs
          list-eduroam-entityIDs = pkgs.writeShellScriptBin "list-eduroam-entityIDs"
            "${pkgs.curl}/bin/curl 'https://cat.eduroam.org/user/API.php?action=listAllIdentityProviders&api' | ${pkgs.jq}/bin/jq";
        });
    };
}
