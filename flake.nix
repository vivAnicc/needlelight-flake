{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    utils = {
      url = "github:vivAnicc/nix-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, utils, ... }: utils.lib.mkFlake (system: let
    pkgs = import nixpkgs {inherit system;};
  in {
    packages.${system} = rec {
      default = needlelight;

      needlelight = pkgs.buildDotnetModule rec {
        pname = "needlelight";
        version = "6.0.0.0";

        src = pkgs.fetchFromGitHub {
          owner = "Aarav2709";
          repo = "Needlelight";
          tag = "v${version}";
          hash = "sha256-WHFBGb9ZIJ7r5FmzW02+bROHMiV4tuOfMLXoYZpvi5Q=";
        };

        # Use .NET 9.0 since 7.0 is EOL
        dotnetFlags = [ "-p:TargetFramework=net9.0" ];

        projectFile = "Needlelight/Needlelight.csproj";

        nugetDeps = ./deps.json;

        dotnet-sdk = pkgs.dotnetCorePackages.sdk_9_0;
        dotnet-runtime = pkgs.dotnetCorePackages.sdk_9_0;

        selfContainedBuild = true;

        passthru.updateScript = pkgs.nix-update-script { };

        runtimeDeps = [
          pkgs.zlib
          pkgs.icu
          pkgs.openssl
        ];

        nativeBuildInputs = [
          pkgs.icoutils
          pkgs.copyDesktopItems
        ];

        executables = [ "Needlelight" ];

        postFixup = ''
          # Icon for the desktop file
          icotool -x $src/Needlelight/Assets/Needlelight.ico
          install -D Needlelight_3_32x32x32.png $out/share/icons/hicolor/32x32/apps/needlelight.png
        '';

        desktopItems = [
          (pkgs.makeDesktopItem {
            desktopName = "Needlelight";
            name = "needlelight";
            exec = "Needlelight";
            icon = "Needlelight";
            comment = "A cross platform mod manager for Hollow Knight and Silksong";
            type = "Application";
            categories = [ "Game" ];
          })
        ];
      };
    };
  });
}
