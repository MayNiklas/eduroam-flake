# eduroam-flake

Install Eduroam on NixOS.

## TDLR for helpdesk people

Installing Eduroam on NixOS is not much different from installing it on other Linux distributions.
Users need to use network-manager and execute the python script provided by the cat.eduroam.org.
Main difference on NixOS: the way we manage dependencies is different.

In case you are not familiar with Nix, but you need to help a NixOS user to install Eduroam, here are two options:

### Using this Nix Flake

Take a look at the `flake.nix` file. All this flake does:

1. Copy the python script into the nix store
2. Execute it with Python3 and the dependencies needed

It should be easy to verify what it does, since all URL's are listed.
The `flake.lock` file contains the hashes of the files.
This README also describes how to extend the flake for other Universities. 


Execute the script from GitHub directly:
```sh
nix run 'github:mayniklas/eduroam-flake'#install-eduroam-university-bonn
```

Execute the script from a local clone:
```sh
git clone https://github.com/MayNiklas/eduroam-flake.git
cd eduroam-flake
nix run .#install-eduroam-university-bonn
```

Warning: Nix flakes are pure. In other words: everything that is fetched needs to be hashed and locked in the `flake.lock` file.
This `flake.nix` will fail to build if the hashes are not correct (e.g. if the Eduroam.py script changes). There is a super easy fix for this:

```sh
# Execute the flake without updating the lock file
nix run 'github:mayniklas/eduroam-flake'#install-eduroam-university-bonn --recreate-lock-file --no-write-lock-file

# Update the flake.lock file
nix flake lock --update-input eduroam-university-bonn
```

### Using a Nix Shell

```sh
# open a shell whith all the dependencies needed
nix-shell -p "python3.withPackages (ps: with ps; [ dbus-python ])"

# execute the script
python3 <your-eduroam.py>

# one liner
nix-shell -p "python3.withPackages (ps: with ps; [ dbus-python ])" --run python3 <your-eduroam.py>
```

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

| University        | entityID | command                                       |
| ----------------- | -------- | --------------------------------------------- |
| Universität Bonn  | 5138     | `nix run .#install-eduroam-university-bonn`   |
| Universität Köln  | 5133     | `nix run .#install-eduroam-university-koeln`  |
| Lund University   | 1338     | `nix run .#install-eduroam-lund-university`   |
| Universität Siegen| 5356     | `nix run .#install-eduroam-university-siegen` |
