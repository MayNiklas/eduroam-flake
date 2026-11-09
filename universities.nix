# to add a new university:
# 1. look up the entityID of the institution with `nix run .#list-eduroam-entityIDs`
# 2. add a new entry to the list, `profile` is only required if the institution has several CAT profiles
# { name = "new"; idp = 1; }
# 3. run `./update.py` to add the id and hash of its installer
[
  { name = "bonn"; idp = 5138; id = 5133; hash = "sha256-1d16Lh3Nidudf4HPLVk+XNkPFCFQLhovQRtby1FCJNA="; }
  { name = "flensburg"; idp = 5186; id = 5188; hash = "sha256-pOBEIJDNMMYlaUeS9emqieVSl+UmV/2S5TPRaU6TEjY="; }
  { name = "koeln"; idp = 5133; id = 5440; hash = "sha256-PYT4zIT1zYGLjf2iLCKwdpHFIerXJ9LblLQVTD+tNbw="; }
  { name = "leipzig"; idp = 5198; profile = "Uni Leipzig"; id = 16715; hash = "sha256-bpWQHzM/znDrEyXilRTOcxmzJ83q8xeaQOtflvb6xbY="; }
  { name = "lund"; idp = 433; id = 1338; hash = "sha256-FWSqG5T7FBsH85b2w5P6N8c3eIzNQ68TJ6z2X76Cy1k="; }
  { name = "roskilde"; idp = 562; profile = "Roskilde University's Eduroam"; id = 949; hash = "sha256-qzQINQ09CCNGhLF1YEsdTBGfVKf4m1XmucgnYpg7tRs="; }
  { name = "strathclyde"; idp = 140; id = 2316; hash = "sha256-Sr+ZN3N967y10SgryCODiOOs3VKMcileTK+sOWnU444="; }
  { name = "tudo"; idp = 5208; id = 5411; hash = "sha256-IUi9yM/q06zj1VlBAzxoQDk9IxoW6wk+8HQRY1TkX38="; }
  { name = "tum"; idp = 5162; id = 5155; hash = "sha256-RlCWHbzBdR3BTes+gpprraOMP4fJYGpV2Y+ot2EWv/Q="; }
  { name = "udl"; idp = 888; id = 5824; hash = "sha256-90+TRr2F/Bhvk2br6A7DdT/ofahhzqmsrdkis6HwsIM="; }
  { name = "vccs"; idp = 8668; id = 11835; hash = "sha256-wX/kyqcSgnrntw1FIa0kYUAsCDIP9wZTiXIFcio5aYE="; }
  { name = "unimi"; idp = 579; profile = "Eduroam unimi - Università degli Studi di Milano"; id = 13554; hash = "sha256-pIkUIjPnLIgHC5XeH73gGe7ao+fuUGLk0guD9FXCIWk="; }
]
