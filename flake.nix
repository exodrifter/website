{
  description = "A flake for building exodrifter's website";
  inputs = {
    utils.url = "github:numtide/flake-utils/v1.0.0";
    nixpkgs.url = "github:NixOS/nixpkgs/24.05";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem(
      system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in {
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              pkgs.nodejs_22
            ];
          };
          packages = rec {
            default = pkgs.buildNpmPackage rec {
              pname = "quartz";
              version = "4.3.1";

              src = pkgs.fetchFromGitHub {
                owner = "jackyzha0";
                repo = "quartz";
                rev = "v${version}";
                hash = "sha256-kID0R/n3ij5uvZ/CXjiLa3oqjghX2U4Zu82huejG6/Q=";
              };

              dontNpmBuild = true;
              makeCacheWritable = true;

              npmDepsHash = "sha256-qgAzMTtFTShj3xUut73DBCbkt7yTwVjthL8hEgRFdIo=";

              installPhase = ''
                runHook preInstall
                npmInstallHook

                cd $out/lib/node_modules/@jackyzha0/quartz

                # Copy our website content
                rm -r ./content
                mkdir content
                cp -r ${./content}/* ./content

                # Override quartz source files
                mv ./quartz/components/index.ts ./quartz/components/index-original.ts
                cp -r ${./quartz}/* ./

                $out/bin/quartz build
                mv public/ $out/public/

                runHook postInstall
              '';
            };
          };
        }
    );
}
