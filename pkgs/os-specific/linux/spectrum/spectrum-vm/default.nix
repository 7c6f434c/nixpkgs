{ stdenv, lib, makeWrapper, utillinux, crosvm, linux, sys-vms }:

stdenv.mkDerivation {
  name = "spectrum-vm";

  src = ./spectrum-vm.in;

  nativeBuildInputs = [ makeWrapper ];

  unpackPhase = ''
    cp $src spectrum-vm.in
  '';

  configurePhase = ''
    substituteAll spectrum-vm.in spectrum-vm
    chmod +x spectrum-vm
  '';

  getopt = "${lib.getBin utillinux}/bin/getopt";
  crosvm = "${lib.getBin crosvm}/bin/crosvm";
  kernel = "${sys-vms.comp.linux}/bzImage";
  rootfs = sys-vms.comp.rootfs.squashfs;

  installPhase = ''
    mkdir -p $out/bin
    cp spectrum-vm $out/bin
  '';

  meta = with lib; {
    description = "Utility for testing Spectrum VM components";
    maintainers = with maintainers; [ qyliss ];
    license = licenses.gpl3Plus;
    inherit (crosvm.meta) platforms;
  };
}
