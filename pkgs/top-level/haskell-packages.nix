{ buildPackages, pkgs
, newScope
}:

let
  # These are attributes in compiler and packages that don't support integer-simple.
  integerSimpleExcludes = [
    "ghc822Binary"
    "ghc863Binary"
    "ghc844"
    "ghcjs"
    "ghcjs84"
    "ghcjs86"
    "integer-simple"
  ];

  haskellLib = import ../development/haskell-modules/lib.nix {
    inherit (pkgs) lib;
    inherit pkgs;
  };

  callPackage = newScope {
    inherit haskellLib;
    overrides = pkgs.haskell.packageOverrides;
  };

  bootstrapPackageSet = self: super: {
    mkDerivation = drv: super.mkDerivation (drv // {
      doCheck = false;
      doHaddock = false;
      enableExecutableProfiling = false;
      enableLibraryProfiling = false;
      enableSharedExecutables = false;
      enableSharedLibraries = false;
    });
  };

  # Use this rather than `rec { ... }` below for sake of overlays.
  inherit (pkgs.haskell) compiler packages;

  # make sure we build cross compiler as technically stage3 compiler. That is
  # we build them with the same version they are instead of the bootstrap compiler.
  # For regular builds we'll use the bootstrap version.
  mkBootPkgs = ver: boot: if pkgs.stdenv.hostPlatform != pkgs.stdenv.targetPlatform then buildPackages.haskell.packages.${ver} else packages.${boot};

in {
  lib = haskellLib;

  compiler = {

    ghc821Binary = callPackage ../development/haskell-modules {
      buildHaskellPackages = bh.packages.ghc821Binary;
      ghc = bh.compiler.ghc821Binary;
      compilerConfig = callPackage ../development/haskell-modules/configuration-ghc-8.2.x.nix { };
      packageSetConfig = bootstrapPackageSet;
    };
    ghc822Binary = callPackage ../development/compilers/ghc/8.2.2-binary.nix { };

    ghc863Binary = callPackage ../development/compilers/ghc/8.6.3-binary.nix { };

    ghc822 = callPackage ../development/compilers/ghc/8.2.2.nix {
      bootPkgs = packages.ghc822Binary;
      inherit (buildPackages.python3Packages) sphinx;
      buildLlvmPackages = buildPackages.llvmPackages_39;
      llvmPackages = pkgs.llvmPackages_39;
    };
    ghc843 = callPackage ../development/haskell-modules {
      buildHaskellPackages = bh.packages.ghc843;
      ghc = bh.compiler.ghc843;
      compilerConfig = callPackage ../development/haskell-modules/configuration-ghc-8.4.x.nix { };
    };
    ghc844 = callPackage ../development/compilers/ghc/8.4.4.nix {
      bootPkgs = packages.ghc822Binary;
      sphinx = buildPackages.python3Packages.sphinx_1_7_9;
      buildLlvmPackages = buildPackages.llvmPackages_5;
      llvmPackages = pkgs.llvmPackages_5;
    };
    ghc864 = callPackage ../development/compilers/ghc/8.6.4.nix {
      bootPkgs = packages.ghc822Binary;
      inherit (buildPackages.python3Packages) sphinx;
      buildLlvmPackages = buildPackages.llvmPackages_6;
      llvmPackages = pkgs.llvmPackages_6;
    };
    ghc862 = callPackage ../development/compilers/ghc/8.6.2.nix {
      bootPkgs = mkBootPkgs "ghc862" "ghc822";
      buildLlvmPackages = buildPackages.llvmPackages_6;
      llvmPackages = pkgs.llvmPackages_6;
    };
    ghc863 = builtins.trace ''

      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      ************************************ WARNING ***********************************
      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

               You are using GHC 8.6.3.  This version is known to
               be busted on windows!  See GHC issue #16057.  Make
               sure you revert commit
                 ghc:ed86e3b531322f74d2c2d00d7ff8662b08fabde6
               before using GHC 8.6.3 in any form on windows.

               --
               https://ghc.haskell.org/trac/ghc/ticket/16057

      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      ************************************ WARNING ***********************************
      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      '' callPackage ../development/compilers/ghc/8.6.3.nix {
      bootPkgs = mkBootPkgs "ghc863" "ghc822";
      buildLlvmPackages = buildPackages.llvmPackages_6;
      llvmPackages = pkgs.llvmPackages_6;
    };
    ghc864 = callPackage ../development/compilers/ghc/8.6.4.nix {
      bootPkgs = mkBootPkgs "ghc864" "ghc822";
      buildLlvmPackages = buildPackages.llvmPackages_6;
      llvmPackages = pkgs.llvmPackages_6;
    };
    ghcHEAD = callPackage ../development/compilers/ghc/head.nix {
      bootPkgs = mkBootPkgs "ghcHEAD" "ghc821Binary";
      buildLlvmPackages = buildPackages.llvmPackages_5;
      llvmPackages = pkgs.llvmPackages_5;
    };
    ghcjs = compiler.ghcjs84;
    # Use `import` because `callPackage inside`.
    ghcjs710 = import ../development/compilers/ghcjs/7.10 {
      bootPkgs = buildPackages.ghc7103;
      inherit (pkgs) cabal-install;
      inherit (buildPackages) fetchgit fetchFromGitHub;
    };
    # `import` on purpose; see above.
    ghcjs80 = import ../development/compilers/ghcjs/8.0 {
      bootPkgs = buildPackages.ghc802;
      inherit (pkgs) cabal-install;
      inherit (buildPackages) fetchgit fetchFromGitHub;
    };
    ghcjs82 = callPackage ../development/compilers/ghcjs-ng {
      bootPkgs = buildPackages.ghc822;
      ghcjsSrcJson = ../development/compilers/ghcjs-ng/8.2/git.json;
      stage0 = ../development/compilers/ghcjs-ng/8.2/stage0.nix;
    };
    ghcjs = compiler.ghcjs86;
    ghcjs84 = callPackage ../development/compilers/ghcjs-ng {
      bootPkgs = buildPackages.ghc843;
      ghcjsSrcJson = ../development/compilers/ghcjs-ng/8.4/git.json;
      stage0 = ../development/compilers/ghcjs-ng/8.4/stage0.nix;
      ghcjsDepOverrides = callPackage ../development/compilers/ghcjs-ng/8.4/dep-overrides.nix {};
    };
    ghcjs86 = callPackage ../development/compilers/ghcjs-ng {
      bootPkgs = packages.ghc864;
      ghcjsSrcJson = ../development/compilers/ghcjs-ng/8.6/git.json;
      stage0 = ../development/compilers/ghcjs-ng/8.6/stage0.nix;
      ghcjsDepOverrides = callPackage ../development/compilers/ghcjs-ng/8.6/dep-overrides.nix {};
    };

    # The integer-simple attribute set contains all the GHC compilers
    # build with integer-simple instead of integer-gmp.
    integer-simple = let
      integerSimpleGhcNames = pkgs.lib.filter
        (name: ! builtins.elem name integerSimpleExcludes)
        (pkgs.lib.attrNames compiler);
    in pkgs.recurseIntoAttrs (pkgs.lib.genAttrs
      integerSimpleGhcNames
      (name: compiler."${name}".override { enableIntegerSimple = true; }));
  } //
  ( if pkgs.stdenv.hostPlatform.isGhcjs
    then {
      ghc802 = compiler.ghcjs80;
      ghc822 = compiler.ghcjs82;
      ghc843 = compiler.ghcjs84;
      ghc844 = compiler.ghcjs84;
      ghc861 = compiler.ghcjs86;
      ghc862 = compiler.ghcjs86;
      ghc863 = compiler.ghcjs86;
      ghc864 = compiler.ghcjs86;
    }
    else {}
  ) //
  ( if pkgs.stdenv.hostPlatform.isAsterius
    then {
      ghc802 = compiler.asterius;
      ghc822 = compiler.asterius;
      ghc843 = compiler.asterius;
      ghc844 = compiler.asterius;
      ghc861 = compiler.asterius;
      ghc862 = compiler.asterius;
      ghc863 = compiler.asterius;
      ghc864 = compiler.asterius;
    }
    else {}
  );

  # Default overrides that are applied to all package sets.
  packageOverrides = self : super : {};

  # Always get compilers from `buildPackages`
  packages = let bh = buildPackages.haskell; in {

    ghc822Binary = callPackage ../development/haskell-modules {
      buildHaskellPackages = bh.packages.ghc822Binary;
      ghc = bh.compiler.ghc822Binary;
      compilerConfig = callPackage ../development/haskell-modules/configuration-ghc-8.2.x.nix { };
      packageSetConfig = bootstrapPackageSet;
    };
    ghc863Binary = callPackage ../development/haskell-modules {
      buildHaskellPackages = bh.packages.ghc863Binary;
      ghc = bh.compiler.ghc863Binary;
      compilerConfig = callPackage ../development/haskell-modules/configuration-ghc-8.6.x.nix { };
      packageSetConfig = bootstrapPackageSet;
    };
    ghc822 = callPackage ../development/haskell-modules {
      buildHaskellPackages = bh.packages.ghc822;
      ghc = bh.compiler.ghc822;
      compilerConfig = callPackage ../development/haskell-modules/configuration-ghc-8.2.x.nix { };
    };
    ghc844 = callPackage ../development/haskell-modules {
      buildHaskellPackages = bh.packages.ghc844;
      ghc = bh.compiler.ghc844;
      compilerConfig = callPackage ../development/haskell-modules/configuration-ghc-8.4.x.nix { };
    };
    ghc864 = callPackage ../development/haskell-modules {
      buildHaskellPackages = bh.packages.ghc864;
      ghc = bh.compiler.ghc864;
      compilerConfig = callPackage ../development/haskell-modules/configuration-ghc-8.6.x.nix { };
    };
    ghc862 = callPackage ../development/haskell-modules {
      buildHaskellPackages = bh.packages.ghc862;
      ghc = bh.compiler.ghc862;
      compilerConfig = callPackage ../development/haskell-modules/configuration-ghc-8.6.x.nix { };
    };
    ghc863 = callPackage ../development/haskell-modules {
      buildHaskellPackages = bh.packages.ghc863;
      ghc = bh.compiler.ghc863;
      compilerConfig = callPackage ../development/haskell-modules/configuration-ghc-8.6.x.nix { };
    };
    ghc864 = callPackage ../development/haskell-modules {
      buildHaskellPackages = bh.packages.ghc864;
      ghc = bh.compiler.ghc864;
      compilerConfig = callPackage ../development/haskell-modules/configuration-ghc-8.6.x.nix { };
    };
    ghcHEAD = callPackage ../development/haskell-modules {
      buildHaskellPackages = bh.packages.ghcHEAD;
      ghc = bh.compiler.ghcHEAD;
      compilerConfig = callPackage ../development/haskell-modules/configuration-ghc-head.nix { };
    };
    ghcjs = packages.ghcjs86;
    ghcjs84 = callPackage ../development/haskell-modules rec {
      buildHaskellPackages = ghc.bootPkgs;
      ghc = bh.compiler.ghcjs84;
      compilerConfig = callPackage ../development/haskell-modules/configuration-ghc-8.4.x.nix { };
      packageSetConfig = callPackage ../development/haskell-modules/configuration-ghcjs.nix { };
    };
    ghcjs86 = callPackage ../development/haskell-modules rec {
      buildHaskellPackages = ghc.bootPkgs;
      ghc = bh.compiler.ghcjs86;
      compilerConfig = callPackage ../development/haskell-modules/configuration-ghc-8.6.x.nix { };
      packageSetConfig = callPackage ../development/haskell-modules/configuration-ghcjs.nix { };
    };

    # The integer-simple attribute set contains package sets for all the GHC compilers
    # using integer-simple instead of integer-gmp.
    integer-simple = let
      integerSimpleGhcNames = pkgs.lib.filter
        (name: ! builtins.elem name integerSimpleExcludes)
        (pkgs.lib.attrNames packages);
    in pkgs.lib.genAttrs integerSimpleGhcNames (name: packages."${name}".override {
      ghc = bh.compiler.integer-simple."${name}";
      buildHaskellPackages = bh.packages.integer-simple."${name}";
      overrides = _self : _super : {
        integer-simple = null;
        integer-gmp = null;
      };
    });

  };
}
