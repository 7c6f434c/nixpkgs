{ stdenv, lib, rustPlatform, fetchFromGitiles, upstreamInfo
, pkgconfig, minijail, dtc, libusb1, libcap, linux
}:

let
  arch = with stdenv.hostPlatform;
    if isAarch64 then "arm"
    else if isx86_64 then "x86_64"
    else throw "no seccomp policy files available for host platform";

  crosvmSrc = fetchFromGitiles
    upstreamInfo.components."chromiumos/platform/crosvm";

  adhdSrc = fetchFromGitiles
    upstreamInfo.components."chromiumos/third_party/adhd";
in

  rustPlatform.buildRustPackage rec {
    pname = "crosvm";
    inherit (upstreamInfo) version;

    unpackPhase = ''
      runHook preUnpack

      mkdir -p chromiumos/platform chromiumos/third_party

      pushd chromiumos/platform
      unpackFile ${crosvmSrc}
      popd

      pushd chromiumos/third_party
      unpackFile ${adhdSrc}
      popd

      chmod -R u+w -- "$sourceRoot"

      runHook postUnpack
    '';

    sourceRoot = "chromiumos/platform/crosvm";

    patches = [
      ./default-seccomp-policy-dir.diff
    ];

    cargoSha256 = "0lhivwvdihslwp81i3sa5q88p5hr83bzkvklrcgf6x73arwk8kdz";

    nativeBuildInputs = [ pkgconfig ];

    buildInputs = [ dtc libcap libusb1 minijail ];

    postPatch = ''
      sed -i "s|/usr/share/policy/crosvm/|$out/share/policy/|g" \
             seccomp/*/*.policy
    '';

    preBuild = ''
      export DEFAULT_SECCOMP_POLICY_DIR=$out/share/policy
    '';

    postInstall = ''
      mkdir -p $out/share/policy/
      cp seccomp/${arch}/* $out/share/policy/
    '';

    CROSVM_CARGO_TEST_KERNEL_BINARY =
      lib.optionalString (stdenv.buildPlatform == stdenv.hostPlatform)
        "${linux}/${stdenv.hostPlatform.platform.kernelTarget}";

    passthru = {
      inherit adhdSrc;
      src = crosvmSrc;
      updateScript = ../update.py;
    };

    meta = with lib; {
      description = "A secure virtual machine monitor for KVM";
      homepage = "https://chromium.googlesource.com/chromiumos/platform/crosvm/";
      maintainers = with maintainers; [ qyliss ];
      license = licenses.bsd3;
      platforms = [ "aarch64-linux" "x86_64-linux" ];
    };
  }
