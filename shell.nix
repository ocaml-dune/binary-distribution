{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    opam
    pkg-config
    gmp
    openssl
    libev
  ];
}
