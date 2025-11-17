#!/usr/bin/env nix-shell
#! nix-shell -i python -p "python3.withPackages (ps: with ps; [ requests ])"

# This script updates the hashes in the universities.nix file

import base64
import hashlib
import json
import subprocess

import requests


def download_and_generate_sha256_hash(url: str) -> str | None:
    """
    Fetch the tarball from the given URL.
    Then generate a sha256 hash of the tarball.
    """

    try:
        # Download the file from the URL
        response = requests.get(url)
        response.raise_for_status()

    except requests.exceptions.RequestException as e:
        print(f"Error: {e}")
        return None

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


universities = json.loads(
    subprocess.check_output(
        "nix eval --json --file ./universities.nix", shell=True
    ).decode("utf-8")
)

for university in universities:
    print(f"Fetching data for {university['name']} ({university['id']})")
    sri_hash = download_and_generate_sha256_hash(
        f"https://cat.eduroam.org/user/API.php?action=downloadInstaller&lang=en&profile={university['id']}&device=linux&generatedfor=user&openroaming=0"
    )
    if university["hash"] is None:
        continue
    elif not sri_hash:
        print("Failed getting hash. Check the university's profile ID.")
    elif sri_hash != university["hash"]:
        print(f"Hash mismatch for {university['name']} ({university['id']})")
        print(f"Expected: {university['hash']}")
        print(f"Actual: {sri_hash}")
        print("-" * 80)
        # search for university['hash'] in the file and replace it with sri_hash
        with open("universities.nix", "r") as file:
            filedata = file.read()
        newdata = filedata.replace(university["hash"], sri_hash)
        with open("universities.nix", "w") as file:
            file.write(newdata)
