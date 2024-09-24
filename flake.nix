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
        { name = "bonn"; id = 5133; }
        { name = "koeln"; id = 5133; }
        { name = "leipzig"; id = 5674; }
        { name = "lund"; id = 1338; }
        { name = "saarland"; id = 10315; }
        { name = "siegen"; id = 5356; }
      ];
    in
    {
      formatter = forAllSystems (system: nixpkgsFor.${system}.nixpkgs-fmt);
      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
          python-with-dbus = pkgs.python3.withPackages (p: with p; [ dbus-python ]);
          mkScript = { name, id, }:
            pkgs.writeShellScriptBin "install-eduroam-${name}" ''
              ${python-with-dbus}/bin/python <(${pkgs.wget}/bin/wget -qO- "https://cat.eduroam.org/user/API.php?action=downloadInstaller&lang=en&profile=${builtins.toString id}&device=linux&generatedfor=user&openroaming=0")
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
