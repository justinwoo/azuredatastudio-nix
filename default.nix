let
  pkgs = import <nixpkgs> {};
in pkgs.stdenv.mkDerivation {
  name = "azuredatastudio";
  src = pkgs.fetchurl {
    url = "https://github.com/Microsoft/azuredatastudio/releases/download/1.3.6/azuredatastudio-linux-1.3.6.tar.gz";
    sha256 = "16n2gqnsf5maxjfvvb2157jdiq4ynsgvaka2bccqnpx66mlp2276";
  };

  phases = "unpackPhase installPhase";

  unpackPhase = ''
    mkdir -p $out/azuredatastudio
    ${pkgs.gnutar}/bin/tar xf $src --strip 1 -C $out/azuredatastudio
  '';

  installPhase = ''
    install -D -m555 $out/azuredatastudio/azuredatastudio $out/bin/azuredatastudio
  '';
}
