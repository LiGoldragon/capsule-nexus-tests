{
  description = "External regression tests for Capsule Nexus";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-build = {
      url = "github:LiGoldragon/rust-build";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    capsule-nexus = {
      url = "github:LiGoldragon/capsule-nexus";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, rust-build, capsule-nexus }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        rust = rust-build.lib.${system}.fromPkgs pkgs;
        prepared = pkgs.runCommand "capsule-nexus-external-test-source" {
          nativeBuildInputs = [ pkgs.patch ];
        } ''
          cp -R ${capsule-nexus} "$out"
          chmod -R u+w "$out"
          patch --fuzz=0 --directory="$out" --strip=1 < ${./patches/external-tests.patch}
          mkdir -p "$out/external-tests"
          cp ${./tests/daemon.rs} "$out/external-tests/daemon.rs"
        '';
        source = rust.cleanSource {
          root = prepared;
          extraFilters = [
            (path: type: type == "regular" && pkgs.lib.hasSuffix ".ethos" (toString path))
          ];
        };
        cargoArtifacts = rust.craneLib.buildDepsOnly {
          src = source;
          cargoExtraArgs = "--workspace --all-features";
        };
      in {
        checks.regressions = rust.craneLib.cargoTest {
          pname = "capsule-nexus-external-regressions";
          version = "0.1.0";
          src = source;
          inherit cargoArtifacts;
          cargoTestExtraArgs = "-p capsule-nexus-daemon --lib --all-features";
        };
      });
}
