{ stdenv
, fetchFromGitHub
, nodejs
, google-cloud-sdk
, brotli
, libpqxx
, python3
}:

stdenv.mkDerivation rec {
  pname = "graphql-engine";
  version = "1.0.0-beta.7";

  src = fetchFromGitHub {
    owner = "hasura";
    repo = pname;
    rev = "v${version}";
    sha256 = "18aim5ww0drjr546gb7p6jvjhm41sy2x7cy9padnq3svacs4kzfs";
  };

  nativeBuildInputs = [
    nodejs
    python3
  ];

  buildInputs = [
    brotli
    google-cloud-sdk
    libpqxx
  ];

  checkInputs = [
  ];

  databaseoCheck = true;

  preConfigure =
    ''
    '';

  buildPhase = ''
    runHook preBuild
    cd console
    npm ci
    npm run server-build
    cd ..
  '';

  meta = with stdenv.lib; {
    description = "GraphQL server that gives you instant, realtime GraphQL APIs over Postgres, with webhook triggers on database events, and remote schemas";
    homepage = https://github.com/hasura/graphql-engine/;
    license = licenses.asl20;
    maintainers = with maintainers; [ craigem ];
    platforms = platforms.linux;
  };
}
