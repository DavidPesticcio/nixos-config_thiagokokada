{
  description = "My Nix{OS} configuration files";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    hardware.url = "github:NixOS/nixos-hardware/master";
    home = {
      url = "github:nix-community/home-manager/release-21.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "unstable";
    };
    flake-utils.url = "github:numtide/flake-utils";
    declarative-cachix.url = "github:jonascarpay/declarative-cachix/master";
    # overlays
    emacs = {
      url = "github:nix-community/emacs-overlay/master";
      inputs.nixpkgs.follows = "unstable";
    };
    nubank.url = "github:nubank/nixpkgs/master";
    # nnn plugins
    nnn-plugins = {
      url = "github:jarun/nnn/v4.0";
      flake = false;
    };
    # ZSH plugins
    zit = {
      url = "github:thiagokokada/zit/master";
      flake = false;
    };
    zim-completion = {
      url = "github:zimfw/completion/master";
      flake = false;
    };
    zim-environment = {
      url = "github:zimfw/environment/master";
      flake = false;
    };
    zim-input = {
      url = "github:zimfw/input/master";
      flake = false;
    };
    zim-git = {
      url = "github:zimfw/git/master";
      flake = false;
    };
    zim-ssh = {
      url = "github:zimfw/ssh/master";
      flake = false;
    };
    zim-utility = {
      url = "github:zimfw/utility/master";
      flake = false;
    };
    pure = {
      url = "github:sindresorhus/pure/main";
      flake = false;
    };
    zsh-autopair = {
      url = "github:hlissner/zsh-autopair/master";
      flake = false;
    };
    zsh-completions = {
      url = "github:zsh-users/zsh-completions/master";
      flake = false;
    };
    zsh-syntax-highlighting = {
      url = "github:zsh-users/zsh-syntax-highlighting/master";
      flake = false;
    };
    zsh-history-substring-search = {
      url = "github:zsh-users/zsh-history-substring-search/master";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home, flake-utils, ... }: {
    nixosConfigurations =
      let
        mkSystem = { modules, system ? "x86_64-linux" }:
          nixpkgs.lib.nixosSystem {
            inherit system modules;
            specialArgs = { inherit self system; };
          };
      in
      {
        miku-nixos = mkSystem { modules = [ ./hosts/miku-nixos ]; };

        mikudayo-nixos = mkSystem { modules = [ ./hosts/mikudayo-nixos ]; };

        mikudayo-nubank = mkSystem { modules = [ ./hosts/mikudayo-nubank ]; };

        mirai-vps = mkSystem { modules = [ ./hosts/mirai-vps ]; };
      };

    # https://github.com/nix-community/home-manager/issues/1510
    homeConfigurations =
      let
        mkHome =
          { username
          , homeDirectory
          , configPath
          , configuration ? ./home-manager
          , deviceType ? "desktop"
          , system ? "x86_64-linux"
          }:
          home.lib.homeManagerConfiguration rec {
            inherit configuration username homeDirectory system;
            stateVersion = "21.05";
            extraSpecialArgs = {
              inherit self system;
              super = {
                device.type = deviceType;
                meta.username = username;
                meta.configPath = configPath;
              };
            };
          };
      in
      {
        home-linux = mkHome rec {
          username = "thiagoko";
          homeDirectory = "/home/${username}";
          configPath = "${homeDirectory}/Projects/nix-config";
        };

        home-macos = mkHome rec {
          configuration = ./home-manager/macos.nix;
          system = "x86_64-darwin";
          username = "thiagoko";
          homeDirectory = "/Users/${username}";
          configPath = "${homeDirectory}/Projects/nix-config";
        };
      };
  } // flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShell = with pkgs; mkShell {
        buildInputs = [
          coreutils
          findutils
          git
          gnumake
          neovim
          nixFlakes
          nixpkgs-fmt
        ];
      };
    }
  );
}
