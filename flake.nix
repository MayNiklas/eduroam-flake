{
  description = "Install eduroam on NixOS systems";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {self, ...} @ inputs:
    with inputs; let
      supportedSystems = ["aarch64-linux" "x86_64-linux"];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system:
        import nixpkgs {
          inherit system;
          overlays = [];
        });
      unis = [
        {
          name = "leipzig";
          url = "https://cat.eduroam.org/user/API.php?action=downloadInstaller&lang=en&profile=5674&device=linux&generatedfor=user&openroaming=0";
        }
        {
          name = "bonn";
          url = "https://cat.eduroam.org/user/API.php?action=downloadInstaller&lang=en&profile=5133&device=linux&generatedfor=user&openroaming=0";
        }
        {
          name = "saarland";
          url = "https://cat.eduroam.org/user/API.php?action=downloadInstaller&lang=en&profile=10315&device=linux&generatedfor=user&openroaming=0";
        }
        {
          name = "siegen";
          url = "https://cat.eduroam.org/user/API.php?action=downloadInstaller&lang=en&profile=5356&device=linux&generatedfor=user&openroaming=0";
        }
        {
          name = "lund";
          url = "https://cat.eduroam.org/user/API.php?action=downloadInstaller&lang=en&profile=1338&device=linux&generatedfor=user&openroaming=0";
        }
        {
          name = "koeln";

          url = "https://cat.eduroam.org/user/API.php?action=downloadInstaller&lang=en&profile=5133&device=linux&generatedfor=user&openroaming=0";
        }
      ];
    in {
      formatter = forAllSystems (system: nixpkgsFor.${system}.nixpkgs-fmt);
      packages = forAllSystems (
        system: let
          pkgs = nixpkgsFor.${system};
          python-with-dbus = pkgs.python3.withPackages (p: with p; [dbus-python]);
          mkScript = {
            name,
            url,
          }:
            pkgs.writeShellScriptBin "install-eduroam-${name}" ''
              "${python-with-dbus}/bin/python3 ${url}"
            '';
        in
          builtins.listToAttrs (builtins.map (item: {
              name = "install-eduroam-${item.name}";
              value = mkScript item;
            })
            unis)
      );
    };
}
