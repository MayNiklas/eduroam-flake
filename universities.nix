# to add a new university:
# 1. add a new entry to the list (change the name and id)
# { name = "new"; id = 1; }
# 2. run `nix build .\#install-eduroam-new`
# 3. add the hash from the error to the list entry
[
  { name = "bonn"; id = 5133; hash = "sha256-X+eq9TXuCfy8Iea8MjFhk/hk+xRnjtpEPmLZgRCvv0E="; }
  { name = "flensburg"; id = 5188; hash = "sha256-cZecZECAkbzMc8vPOM0DsHh2HkbRxO/AyyOj0sQ7Gmg="; }
  { name = "koeln"; id = 5133; hash = "sha256-X+eq9TXuCfy8Iea8MjFhk/hk+xRnjtpEPmLZgRCvv0E="; }
  { name = "leipzig"; id = 5674; hash = "sha256-75mHJNXiP+SOeoMQhmfbYm97TqYHVJejxCKeT5l5Qc8="; }
  { name = "lund"; id = 1338; hash = "sha256-Nln7adqpalZkqSM5AOkN2U1CAQ/T3BmJkNEMeDU4YDg="; }
  { name = "saarland"; id = 10315; hash = "sha256-4OvnApFKD3zz0Xh/y7S6C1uRvyhgPCKBYHd/bhnmeeo="; }
  { name = "siegen"; id = 5356; hash = "sha256-qBGoeIWfYvDVZaxK6uEjPdIaKeBll0UYIEtoN8swInk="; }
  { name = "vccs"; id = 11835; hash = "sha256-K57+R1cuubAGIyewy9kFWNxwbiuoxAxDecqM3zcv3KY="; }
  { name = "strathclyde"; id = 2316; hash = "sha256-oumaKcSRF8RrdQ0dHbNXN8w6Y5YlLNXnuglVq9srvU0="; }
  { name = "udl"; id = 5824; hash = "sha256-J4fJkCrncDWPJPoXFz3kC7Qwiz1ip/XpgBYVLafc8YM="; }
]
