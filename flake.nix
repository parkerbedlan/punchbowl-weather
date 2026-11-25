{
  description = "Punchbowl Weather dev env: Ruby 4.0.6, Node 24.19.0, yarn";

  inputs = {
    # Pinned to a nixos-unstable revision from 2026-08-17. That revision has
    # ruby_4_0 = 4.0.6 (the Gemfile pins it exactly) and nodejs_24 = 24.19.0
    # (frontend/.tool-versions). Later revisions moved both versions on.
    nixpkgs.url = "github:nixos/nixpkgs/991eb3e01305e9549d0fc5504d034359ae0897a3";
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forEachSystem = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShells = forEachSystem (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            ruby_4_0
            nodejs_24
            (yarn.override { nodejs = nodejs_24; })
            sqlite
            mprocs
            libyaml
            openssl
            pkg-config
          ];

          # Gems go in a directory of their own, outside the repo. A GEM_HOME
          # inherited from the host points at gems built for another Ruby.
          shellHook = ''
            export GEM_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}/punchbowl-weather/gems"
            export GEM_PATH="$GEM_HOME"
            export PATH="$GEM_HOME/bin:$PATH"
            unset BUNDLE_APP_CONFIG
          '';
        };
      });
    };
}
