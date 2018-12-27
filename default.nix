{ pkgs ? import <nixpkgs> {} }:

let
  dynamic-linker = pkgs.stdenv.cc.bintools.dynamicLinker;

in pkgs.stdenv.mkDerivation rec {
  name = "azuredatastudio";
  src = pkgs.fetchurl {
    url = "https://github.com/Microsoft/azuredatastudio/releases/download/1.3.6/azuredatastudio-linux-1.3.6.tar.gz";
    sha256 = "16n2gqnsf5maxjfvvb2157jdiq4ynsgvaka2bccqnpx66mlp2276";
  };

  phases = "unpackPhase fixupPhase";

  unpackPhase = ''
    mkdir -p $out
    ${pkgs.gnutar}/bin/tar xf $src --strip 1 -C $out
  '';

  rpath = with pkgs; lib.concatStringsSep ":" [
    atomEnv.libPath
    "$out"
    "$out/resources/app/extensions/mssql/sqltoolsservice/Linux/1.5.0-alpha.60"
  ];

  fixupPhase = ''
    patchelf \
      --set-interpreter "${dynamic-linker}" \
      --set-rpath "${rpath}" \
      $out/azuredatastudio
  '';
}
