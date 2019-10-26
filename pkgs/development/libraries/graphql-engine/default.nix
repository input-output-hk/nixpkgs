{ haskellPackages, haskell }:

haskellPackages.override {
  overrides = self: super: {
    ci-info = self.callPackage ./ci-info.nix {};
    graphql-engine = haskell.lib.dontCheck (self.callPackage ./graphql-engine.nix {});
    graphql-parser = self.callPackage ./graphql-parser.nix {};
    #multi-ghc-travis = self.callPackage ./multi-ghc-travis.nix {};
    pg-client = self.callPackage ./pg-client.nix {};
    shakespeare = self.callHackageDirect { pkg = "shakespeare"; ver = "2.0.22"; sha256 = "1d7byyrc2adyxrgcrlxyyffpr4wjcgcnvdb8916ad6qpqjhqxx72"; } {};
    stm-hamt = haskell.lib.doJailbreak super.stm-hamt;
    superbuffer = haskell.lib.doJailbreak super.superbuffer;
  };
}
