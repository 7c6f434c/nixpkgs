{
  lib,
  fetchFromGitHub,
  installShellFiles,
  python3Packages,
  perl,
  ffmpeg,
  gitMinimal,
}:

let

  inherit (python3Packages)
    buildPythonApplication
    setuptools
    requests
    pysocks
    cryptography
    pyyaml
    nose3
    pytest
    mock
    requests-mock
    ;

  version = "4.97.1";

in

buildPythonApplication {
  pname = "svtplay-dl";
  inherit version;
  pyproject = true;

  src = fetchFromGitHub {
    owner = "spaam";
    repo = "svtplay-dl";
    rev = version;
    hash = "sha256-9h3hHRRL7DKeCpEXL5w72hYi1nTS+a+x5e9ArMmVgYQ=";
  };

  build-system = [ setuptools ];

  dependencies = [
    requests
    pysocks
    cryptography
    pyyaml
  ];

  nativeBuildInputs = [
    # For `pod2man(1)`.
    perl
    installShellFiles
  ];

  nativeCheckInputs = [
    nose3
    pytest
    mock
    requests-mock
    gitMinimal
  ];

  postBuild = ''
    make svtplay-dl.1
  '';

  doCheck = python3Packages.pythonOlder "3.12";

  checkPhase = ''
    runHook preCheck

    nosetests --all-modules --with-doctest

    runHook postCheck
  '';

  postInstall = ''
    installManPage svtplay-dl.1
    makeWrapperArgs+=(--prefix PATH : "${lib.makeBinPath [ ffmpeg ]}")
  '';

  postInstallCheck = ''
    $out/bin/svtplay-dl --help > /dev/null
  '';

  meta = {
    homepage = "https://github.com/spaam/svtplay-dl";
    description = "Command-line tool to download videos from svtplay.se and other sites";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "svtplay-dl";
  };
}
