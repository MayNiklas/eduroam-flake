# Wraps a password file into the environment file read by NetworkManager-ensure-profiles.
# usage: write-password-env.py <password file> <out file>
#
# The value passes two parsers:
# 1. systemd's EnvironmentFile=, which unescapes \" \\ \` \$ in a double-quoted value
#    and keeps all other escapes (src/basic/env-file.c)
# 2. NetworkManager's keyfile (GKeyFile), into which envsubst pastes the value verbatim

import re
import sys

KEYFILE_ESCAPES = {"\\": "\\\\", " ": "\\s", "\t": "\\t", "\n": "\\n", "\r": "\\r"}


def keyfile_escape(value: str) -> str:
    return "".join(KEYFILE_ESCAPES.get(char, char) for char in value)


def systemd_escape(value: str) -> str:
    return '"' + re.sub(r'([\\"`$])', r"\\\1", value) + '"'


if __name__ == "__main__":
    password_file, out = sys.argv[1:]
    try:
        # newline="" keeps carriage returns inside the password, the trailing line break is removed
        with open(password_file, encoding="utf-8", newline="") as file:
            password = file.read().rstrip("\r\n")
    except OSError as e:
        sys.exit(f"write-password-env: cannot read {password_file}: {e.strerror}")
    except UnicodeDecodeError:
        sys.exit(f"write-password-env: {password_file} is not UTF-8 encoded")
    if not password:
        sys.exit(f"write-password-env: {password_file} is empty")

    with open(out, "w", encoding="utf-8") as file:
        file.write(f"EDUROAM_PASSWORD={systemd_escape(keyfile_escape(password))}\n")
