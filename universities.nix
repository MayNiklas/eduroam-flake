# to add a new university:
# 1. add a new entry to the list (change the name and id)
# { name = "new"; id = 1; }
# 2. run `nix build .\#install-eduroam-new`
# 3. add the hash from the error to the list entry
[
  { name = "bonn"; id = 5133; hash = "sha256-2VnpEu2na6HeQADVUdlR4d8IAIS1RP7kXavGRtSgLqI="; }
  { name = "flensburg"; id = 5188; hash = "sha256-RrYwPolob6+xwQn8MTPHVLUI/W4oNYAFSAtHEc0dNR0="; }
  { name = "koeln"; id = 5133; hash = "sha256-2VnpEu2na6HeQADVUdlR4d8IAIS1RP7kXavGRtSgLqI="; }
  { name = "leipzig"; id = 5674; hash = "sha256-TEYTR8TeRNIIZcUx01j9pfedkk0PF5XuXPAVUyI136E="; }
  { name = "lund"; id = 1338; hash = "sha256-wFE3m9NKq3RkPXdbwVOuhHkozI2J2qvVjnVwjq9qAK4="; }
  { name = "roskilde"; id = 949; hash = "sha256-OHDUOWRT6jak8uKRnwDI7WBAsG0AuiHekOQ8LOnzchQ="; }
  { name = "siegen"; id = 5356; hash = "sha256-oiCKmaFXbLz+q8bbYx7ZkstDr0bQOOUv/mcktMzFQ90="; }
  { name = "strathclyde"; id = 2316; hash = "sha256-pJ8geu1MToF9VSJth+BgJ/ut0rwBnseGD+WILsPcWZI="; }
  { name = "tudo"; id = 5411; hash = "sha256-/aRaVJIGNkmMNb2gIL04/l+N5cqU/bJzxod9DR4/NeQ="; }
  { name = "tum"; id = 5155; hash = "sha256-MhkJhdgyx4F+7xtWAHsjIcLD8zH3sK8cA5P6IDlllHY="; }
  { name = "udl"; id = 5824; hash = "sha256-J4fJkCrncDWPJPoXFz3kC7Qwiz1ip/XpgBYVLafc8YM="; }
  { name = "vccs"; id = 11835; hash = "sha256-iMvG6oEoa7HvIkZwaOsU1tUuGnHk8+LNHlzlRPeZa44="; }
]
