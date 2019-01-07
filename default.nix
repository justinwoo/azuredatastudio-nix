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

  targetPath = "$out/azuredatastudio";

  unpackPhase = ''
    mkdir -p ${targetPath}
    ${pkgs.gnutar}/bin/tar xf $src --strip 1 -C ${targetPath}
  '';

  rpath = with pkgs; lib.concatStringsSep ":" [
    atomEnv.libPath
    targetPath
    "${targetPath}/resources/app/extensions/mssql/sqltoolsservice/Linux/1.5.0-alpha.60"
  ];

  fixupPhase = ''
    patchelf \
      --set-interpreter "${dynamic-linker}" \
      --set-rpath "${rpath}" \
      ${targetPath}/azuredatastudio

    mkdir -p $out/bin
    ln -s ${targetPath}/azuredatastudio $out/bin/azuredatastudio
  '';
}
