# eduroam-flake

Install Eduroam on NixOS.

## TDLR for helpdesk people

Installing Eduroam on NixOS is not much different from installing it on other Linux distributions.
Users need to use network-manager and execute the python script provided by the cat.eduroam.org.
Main difference on NixOS: the way we manage dependencies is different.

In case you are not familiar with Nix, but you need to help a NixOS user to install Eduroam, here are two options:

### Using this Nix Flake

Take a look at the `flake.nix` file. All this flake does:

1. fetch the python script
2. Execute it with Python3 and the dependencies needed

The URLs are generated from the eduroam ID corresponding to your institution.

Execute the script from GitHub directly:

```sh
nix run 'github:mayniklas/eduroam-flake'#install-eduroam-bonn
```

Execute the script from a local clone:

```sh
git clone https://github.com/MayNiklas/eduroam-flake.git
cd eduroam-flake
nix run .#install-eduroam-bonn
```

or list all available scripts with `nix flake show`

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

Then add your university to the list using it's name and the id that is used to fetch the script.

Then run the `nix run` command.

The first run will fail, because the hash of the python script is not known yet.
The error message will tell you the hash of the python script.
Add the hash to the university's entry.

Nice to know:
To build a Nix package, just run `nix build .#install-eduroam-bonn`.
The result will be in `result`. You can run it with `./result/bin/install-eduroam-bonn`.
Reviewing this file manually tells us a lot about how Nix works!

## Supported Universities:

| University                        | entityID | command                                |
| --------------------------------- | -------- | -------------------------------------- |
| Universität Bonn                  | 5138     | `nix run .#install-eduroam-bonn`       |
| Hochschule Flensburg              | 5188     | `nix run .#install-eduroam-flensburg`  |
| Universität Köln                  | 5133     | `nix run .#install-eduroam-koeln`      |
| Lund University                   | 1338     | `nix run .#install-eduroam-lund` |
| Universität Siegen                | 5356     | `nix run .#install-eduroam-siegen`     |
| University Leipzig                | 5674     | `nix run .#install-eduroam-leipzig`    |
| Virginia Community College System | 11835    | `nix run .#install-eduroam-vccs`       |
| University of Strathclyde         | 2316     | `nix run .#install-eduroam-strathclyde`|
| University of Lleida              | 5824     | `nix run .#install-eduroam-udl        `|
| Technical University of Munich    | 5155     | `nix run .#install-eduroam-tum        `|
