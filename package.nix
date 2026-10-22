{ 
  rustPlatform, 
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname   = "nixus";
  version = "0.1.0";

  src = ./.;

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  doCheck = false;
})
