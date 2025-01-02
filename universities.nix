# to add a new university:
# 1. add a new entry to the list (change the name and id)
# { name = "new"; id = 1; }
# 2. run `nix build .\#install-eduroam-new`
# 3. add the hash from the error to the list entry
[
  {
    name = "bonn";
    id = 5133;
    hash = "sha256-uPVriEsQAkjibFm0E2xXtXyD2UVddjPMv2gQfRgKIao=";
  }
  {
    name = "flensburg";
    id = 5188;
    hash = "sha256-RRnZbVbFg86GXIOxVChO2e5OoOWu0uzb/3IviECH1GU=";
  }
  {
    name = "koeln";
    id = 5133;
    hash = "sha256-uPVriEsQAkjibFm0E2xXtXyD2UVddjPMv2gQfRgKIao=";
  }
  {
    name = "leipzig";
    id = 5674;
    hash = "sha256-Clybdol+M5yRYBDxst+14ffThQ/VDYaYeUo6FYyGMpg=";
  }
  {
    name = "lund";
    id = 1338;
    hash = "sha256-Nln7adqpalZkqSM5AOkN2U1CAQ/T3BmJkNEMeDU4YDg=";
  }
  {
    name = "saarland";
    id = 10315;
    hash = "sha256-JPR4qeU4TXkaxeDhnXN+DJ8h3Sz5K8b+FNm3UhPoo1I=";
  }
  {
    name = "siegen";
    id = 5356;
    hash = "sha256-fyUno1PytodSyV/fMKqdfAGHZxa3C3m2Nfeskkaotnk=";
  }
  {
    name = "vccs";
    id = 11835;
    hash = "sha256-CdO0zwkhBbhkH53yzPMr+EwflZjUTPeOY1XVKHEwIKY=";
  }
]
