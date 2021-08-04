{ lib, fetchpatch, fetchzip, yarn2nix-moretea, nodejs, jq, dos2unix }:
yarn2nix-moretea.mkYarnPackage rec {
  version = "0.8.87";

  src = fetchzip {
    url = "https://registry.npmjs.org/meshcentral/-/meshcentral-0.8.87.tgz";
    sha256 = "1jb65pvbld83mdjdb4f4z2brqsdh3b1mvnjdhbllcsn35m705cp5";
  };

  packageJSON = ./package.json;
  yarnLock = ./yarn.lock;
  yarnNix = ./yarn.nix;

  # Tarball has CRLF line endings. This makes patching difficult, so let's convert them.
  nativeBuildInputs = [ dos2unix ];
  prePatch = ''
    find . -name '*.js' -exec dos2unix {} +
    ln -snf meshcentral.js bin/meshcentral
  '';

  preFixup = ''
    mkdir -p $out/bin
    chmod a+x $out/libexec/meshcentral/deps/meshcentral/meshcentral.js
    sed -i '1i#!${nodejs}/bin/node' $out/libexec/meshcentral/deps/meshcentral/meshcentral.js
    ln -s $out/libexec/meshcentral/deps/meshcentral/meshcentral.js $out/bin/meshcentral
  '';

  publishBinsFor = [ ];

  meta = with lib; {
    description = "Computer management web app";
    homepage = "https://meshcentral.com/info/";
    maintainers = [ maintainers.lheckemann ];
    license = licenses.asl20;
  };
}
