#!/usr/bin/env nix-shell
#! nix-shell -i python -p "python3.withPackages (ps: with ps; [ requests ])"

# This script updates the ids and hashes in the universities.nix file

import subprocess
import sys
import hashlib
import base64
import json
import requests

API_URL = "https://cat.eduroam.org/user/API.php"
# the order of the attributes in universities.nix
KEYS = ["name", "idp", "profile", "id", "hash"]


class UpdateError(Exception):
    """
    The cause of a failed update and what to do about it.
    """


def query_api(params: dict) -> requests.Response:
    response = requests.get(API_URL, params={"lang": "en", **params})
    response.raise_for_status()
    return response


def list_profiles(idp: int) -> list:
    try:
        profiles = query_api({"action": "listProfiles", "api_version": 2, "idp": idp}).json()["data"]
    except requests.RequestException as e:
        # CAT answers an unknown entityID with 500
        raise UpdateError(f'CAT has no institution {idp} or is unavailable ({e}), check "idp" with `nix run .#list-eduroam-entityIDs`') from e
    if not profiles:
        raise UpdateError(f"institution {idp} offers no profiles anymore")
    return profiles


def find_profile(university: dict, profiles: list) -> dict:
    """
    Find the profile by its name.
    Otherwise keep the current profile as long as the institution offers it, as profiles get renamed.
    Otherwise fall back to the only profile of the institution.
    """
    for matching_profiles in (
        [p for p in profiles if p["display"] == university.get("profile")],
        [p for p in profiles if p["id"] == str(university.get("id"))],
        profiles,
    ):
        if len(matching_profiles) == 1:
            return matching_profiles[0]

    names = ", ".join(f'"{p["display"]}"' for p in profiles)
    cause = f'profile "{university["profile"]}" not found' if "profile" in university else "institution has several profiles"
    raise UpdateError(f'{cause}, set "profile" to one of: {names}')


def check_linux_installer(profile_id: str) -> None:
    try:
        devices = query_api({"action": "profileAttributes", "api_version": 2, "profile": profile_id}).json()["data"]["devices"]
    except requests.RequestException as e:
        raise UpdateError(f"could not read the attributes of profile {profile_id} ({e})") from e

    linux = next((d for d in devices if d["id"] == "linux"), None)
    if linux is None or linux.get("redirect"):
        redirects = [d["redirect"] for d in devices if d.get("redirect")]
        raise UpdateError(f"profile {profile_id} offers no Linux installer" + (f", it redirects to {redirects[0]}" if redirects else ""))


def download_and_generate_sha256_hash(url: str) -> str:
    """
    Fetch the tarball from the given URL.
    Then generate a sha256 hash of the tarball.
    """

    try:
        # Download the file from the URL
        response = requests.get(url)
        response.raise_for_status()

    except requests.exceptions.RequestException as e:
        raise UpdateError(f"could not download the installer ({e})") from e

    # Create a new SHA-256 hash object
    sha256_hash = hashlib.sha256()

    # Update the hash object with chunks of the downloaded content
    for byte_block in response.iter_content(4096):
        sha256_hash.update(byte_block)

    # Get the hexadecimal representation of the hash
    hash_value = sha256_hash.digest()

    # Encode the hash value in base64
    base64_hash = base64.b64encode(hash_value).decode("utf-8")

    # Format it as "sha256-{base64_hash}"
    sri_representation = f"sha256-{base64_hash}"

    return sri_representation


def to_nix(value) -> str:
    # JSON strings and numbers are valid Nix, apart from string interpolation
    return json.dumps(value, ensure_ascii=False).replace("${", "\\${")


universities = json.loads(
    subprocess.check_output(
        "nix eval --json --file ./universities.nix", shell=True
    ).decode("utf-8")
)

failures = {}

for university in universities:
    print(f"Fetching data for {university['name']} ({university['idp']})")
    try:
        profile = find_profile(university, list_profiles(university["idp"]))
        check_linux_installer(profile["id"])
        sri_hash = download_and_generate_sha256_hash(
            f"https://cat.eduroam.org/user/API.php?action=downloadInstaller&lang=en&profile={profile['id']}&device=linux&generatedfor=user&openroaming=0"
        )
    except UpdateError as e:
        # the entry keeps the last known installer, the build fails if it is no longer available
        print(f"Error: {e}")
        failures[university["name"]] = e
        continue
    university["id"] = int(profile["id"])
    university["hash"] = sri_hash

# keep the comments above the list, one university per line keeps the diffs readable
with open("universities.nix", "r") as file:
    header = file.read().partition("[\n")[0]
with open("universities.nix", "w") as file:
    file.write(header + "[\n")
    for university in universities:
        attributes = " ".join(f"{key} = {to_nix(university[key])};" for key in KEYS if key in university)
        file.write(f"  {{ {attributes} }}\n")
    file.write("]\n")

if failures:
    sys.exit("Could not update:\n" + "\n".join(f"- {name}: {error}" for name, error in failures.items()))
