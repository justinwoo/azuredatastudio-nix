{ pkgs ? import <nixpkgs> {} }:

let
  dynamic-linker = pkgs.stdenv.cc.bintools.dynamicLinker;

in pkgs.stdenv.mkDerivation rec {
  name = "azuredatastudio";
  src = pkgs.fetchurl {
    url = "https://github.com/Microsoft/azuredatastudio/releases/download/1.3.8/azuredatastudio-linux-1.3.8.tar.gz";
    sha256 = "0aq8s6sa4mxbwgqg4j2g720fn07gfyiw14fl6742jlwhssx0zy9s";
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
    ln -s ${targetPath}/bin/azuredatastudio $out/bin/azuredatastudio
  '';
}
