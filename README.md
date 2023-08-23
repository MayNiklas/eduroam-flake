# eduroam-flake

Install Eduroam on NixOS.

## Disclaimer

This is technically completely overkill and unnecessary.
You don't need to create a package to execute a python script when using Nix.

```sh
nix-shell -p "python3.withPackages (ps: with ps; [ dbus-python ])" --run python3 <your-eduroam.py>
```

Would technically achieve the same result.

Next month I'm giving a talk about Nix and since we need to login into Eduroam during a live demo, I thought it would be a great and simple example to talk about flakes.

Also: it took me some time to figure out, you need to use `dbus-python` instead of `pydbus`. This repository might save people time in case they find it by googling `NixOS Eduroam`. This repository might be helpful for documentation purposes.

## Usage

> This script assumes you are using NetworkManager.

Find your University's entityID:

```sh
nix run .#list-eduroam-entityIDs
```

Create a new entry under `inputs` as well as in the `packages`section of `flake.nix`.

Then run the `nix run` command.

Nice to know:
To build a Nix package, just run `nix build .#install-eduroam-bonn`.
The result will be in `result`. You can run it with `./result/bin/install-eduroam-bonn`.
Reviewing this file manually tells us a lot about how Nix works!

## Supported Universities:

| University       | entityID | command                                      |
| ---------------- | -------- | -------------------------------------------- |
| Universität Bonn | 5138     | `nix run .#install-eduroam-university-bonn`  |
| Universität Köln | 5133     | `nix run .#install-eduroam-university-koeln` |
