{ pkgs ? import <nixpkgs> {} }:

let
  dynamic-linker = pkgs.stdenv.cc.bintools.dynamicLinker;

in pkgs.stdenv.mkDerivation rec {
  name = "azuredatastudio";
  src = pkgs.fetchurl {
    url = "https://github.com/Microsoft/azuredatastudio/releases/download/1.4.5/azuredatastudio-linux-1.4.5.tar.gz";
    sha256 = "1x8rpwdhy7nvlfrz4lm7cla4dk2x1dahzg3hzinjmhhzw948x4z7";
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
    "${targetPath}/resources/app/extensions/mssql/sqltoolsservice/Linux/1.5.0-alpha.71"
  ];

  fixupPhase = ''
    patchelf \
      --set-interpreter "${dynamic-linker}" \
      --set-rpath "${rpath}" \
      ${targetPath}/azuredatastudio

    mkdir -p $out/bin
    ln -s ${targetPath}/bin/azuredatastudio $out/bin/azuredatastudio
  '';
}
