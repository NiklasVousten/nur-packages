{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "crab-hole";
  version = "0.1.9";

  src = fetchFromGitHub {
    owner = "LuckyTurtleDev";
    repo = pname;
    rev = "v${version}"; 
    hash = "sha256-mLS1eo0Z5CjljjWAYynFct2EgV/ylDzt7/eUHV9iqBE=";
  };

  cargoHash = "sha256-k9KsDwRx3lp4k8K63svJsixX6VDXrtVa58M09ukQ9kw=";

  meta = {
    description = "Pi-Hole clone written in rust using hickory-dns/trust-dns";
    homepage = "https://github.com/LuckyTurtleDev/crab-hole";
    license = lib.licenses.agpl3Plus;
    mainProgram = "crab-hole";
    maintainers = [];
  };
}
