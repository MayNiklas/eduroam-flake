# Tests write-password-env.py against GLib's keyfile parser, which NetworkManager uses,
# and a port of systemd's EnvironmentFile= parser for double-quoted values.
# usage: write-password-env-test.py, run by `nix flake check`

import importlib.util
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

from gi.repository import GLib

SCRIPT = Path(__file__).with_name("write-password-env.py")
spec = importlib.util.spec_from_file_location("write_password_env", SCRIPT)
write_password_env = importlib.util.module_from_spec(spec)
spec.loader.exec_module(write_password_env)

PASSWORDS = [
    "secret",
    " leading and trailing space ",
    "tab\t newline\n carriage return\r end",
    "backslash \\ and an escape sequence \\s",
    "quotes \" ' `",
    "$EDUROAM_PASSWORD ${HOME} $(id)",
    "#;=[]%",
    "pässwörd ✓",
]


def keyfile_unescape(value: str) -> str:
    data = f"[802-1x]\npassword={value}\n"
    key_file = GLib.KeyFile()
    key_file.load_from_data(data, len(data.encode()), GLib.KeyFileFlags.NONE)
    return key_file.get_string("802-1x", "password")


def systemd_unescape(value: str) -> str:
    """
    Port of the DOUBLE_QUOTE_VALUE states of parse_env_file_internal() in systemd's src/basic/env-file.c
    """
    assert value.startswith('"') and value.endswith('"'), value
    unescaped = ""
    chars = iter(value[1:-1])
    for char in chars:
        assert char != '"', f"unescaped quote in {value}"
        if char == "\\":
            char = next(chars)
            if char == "\n":
                continue
            if char not in '"\\`$':
                unescaped += "\\"
        unescaped += char
    return unescaped


class WritePasswordEnvTest(unittest.TestCase):
    def test_keyfile_escape(self):
        for password in PASSWORDS:
            with self.subTest(password=password):
                self.assertEqual(keyfile_unescape(write_password_env.keyfile_escape(password)), password)

    def test_systemd_escape(self):
        for password in PASSWORDS:
            with self.subTest(password=password):
                self.assertEqual(systemd_unescape(write_password_env.systemd_escape(password)), password)

    def test_main(self):
        for password in PASSWORDS:
            for line_ending in ["", "\n", "\r\n"]:
                with self.subTest(password=password, line_ending=line_ending):
                    self.assert_main(password, line_ending)

    def assert_main(self, password: str, line_ending: str):
        with tempfile.TemporaryDirectory() as directory:
            password_file, env_file = Path(directory, "password"), Path(directory, "password.env")
            password_file.write_bytes((password + line_ending).encode())
            subprocess.run([sys.executable, SCRIPT, password_file, env_file], check=True)

            key, _, value = env_file.read_text(encoding="utf-8").removesuffix("\n").partition("=")
            self.assertEqual(key, "EDUROAM_PASSWORD")
            self.assertEqual(keyfile_unescape(systemd_unescape(value)), password)

    def test_errors(self):
        for name, content, error in [
            ("missing", None, "cannot read {}: No such file or directory"),
            ("empty", b"\n", "{} is empty"),
            ("not UTF-8", b"\xff\n", "{} is not UTF-8 encoded"),
        ]:
            with self.subTest(name), tempfile.TemporaryDirectory() as directory:
                password_file, env_file = Path(directory, "password"), Path(directory, "password.env")
                if content is not None:
                    password_file.write_bytes(content)
                result = subprocess.run([sys.executable, SCRIPT, password_file, env_file], capture_output=True, text=True)

                self.assertEqual(result.returncode, 1)
                self.assertEqual(result.stderr, f"write-password-env: {error.format(password_file)}\n")
                self.assertFalse(env_file.exists())


if __name__ == "__main__":
    unittest.main()
