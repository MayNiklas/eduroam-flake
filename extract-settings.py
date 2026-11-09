# Extracts the connection settings of an eduroam CAT installer for the NixOS module.
# usage: extract-settings.py <installer.py> <out dir>

import importlib.machinery
import importlib.util
import json
import sys
from pathlib import Path

installer_path, out = sys.argv[1], Path(sys.argv[2])
# the installer parses the command line on import
sys.argv = [installer_path]

loader = importlib.machinery.SourceFileLoader("installer", installer_path)
installer = importlib.util.module_from_spec(importlib.util.spec_from_loader("installer", loader))
loader.exec_module(installer)
config = installer.Config

out.mkdir()
(out / "ca.pem").write_text(config.CA)
(out / "settings.json").write_text(json.dumps({
    "ssids": config.ssids,
    "eapOuter": config.eap_outer,
    "eapInner": config.eap_inner,
    "anonymousIdentity": config.anonymous_identity,
    "userRealm": config.user_realm,
    "serverDomain": config.servers_cn,
}, indent=2))
