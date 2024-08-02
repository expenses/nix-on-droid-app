{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    gradle2nix-flake.url = "github:tadfisher/gradle2nix/v2";
    android-nixpkgs.url = "github:tadfisher/android-nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      gradle2nix-flake,
      android-nixpkgs,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        inherit (gradle2nix-flake.packages.${system}) gradle2nix;
        android-sdk = android-nixpkgs.sdk.${system} (
          sdkPkgs: with sdkPkgs; [
            cmdline-tools-latest
            platforms-android-30
            build-tools-30-0-3
            build-tools-30-0-2
            ndk-22-1-7171670
            ndk-23-1-7779620
            ndk-21-4-7075529
          ]
        );
        ANDROID_HOME = "${android-sdk}/share/android-sdk";
      in
      {
        devShells.default =
          with pkgs;
          mkShell rec {
            inherit ANDROID_HOME;
            buildInputs = [
              gradle2nix
              jdk11
            ];
          };
        /*packages.default = gradle2nix-flake.builders.${system}.buildGradlePackage {
          name = "termux-app";
          lockFile = ./gradle.lock;
          src = pkgs.lib.cleanSource ./.;
          version = "0.1.0";
          gradleBuildFlags = [ "build" ];
          postBuild = ''
            mv app/build/outputs/apk $out
          '';
          inherit ANDROID_HOME;
          overrides = pkgs.callPackage ./nix/patch-aapt2.nix { gradleLock = ./gradle.lock; };
        };*/
      }
    );
}
