{
  description = "Flake to build GenerateAnswerFile using existing default.nix";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  
  outputs = { self, nixpkgs }: 
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      dotnetCorePackages = pkgs.dotnetCorePackages;
    in {
      # Define packages
      packages.x86_64-linux.GenerateAnswerFile = pkgs.callPackage ./default.nix {
        inherit (pkgs) buildDotnetModule;
        dotnetCorePackages = dotnetCorePackages;
      };

      # Set the default package for this system
      defaultPackage.x86_64-linux = self.packages.x86_64-linux.GenerateAnswerFile;

      # Dev shell
      devShells.x86_64-linux.default = pkgs.mkShell {
        buildInputs = [ (
          with dotnetCorePackages;
          combinePackages [
            sdk_8_0
            sdk_9_0
          ]
        )];

        shellHook = ''
          # Define a custom command
          fetch-deps() {
              echo "Building package.fetch-deps..."
              local drv
              drv=$(nix-build -E '
                let
                  pkgs = import <nixpkgs> {};
                in
                  (import ./default.nix {
                    inherit (pkgs) buildDotnetModule dotnetCorePackages;
                  }).fetch-deps
              ')
              echo "Running $drv ..."
              "$drv"
          }
           
          # Optional: show a message when entering the shell
          echo "Welcome to the development shell! Type 'fetch-deps' to build and run the fetch-deps script."
        '';
      };
    };
}
