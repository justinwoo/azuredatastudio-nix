{ pkgs ? import <nixpkgs> {} }:

let ads = import ./default.nix { inherit pkgs; };
in pkgs.runCommand "azuredatastudio-test" {
  buildInputs = [ads];
  shellHook = ''
    export PATH=${ads.outPath}/bin:$PATH
  '';
} ""
