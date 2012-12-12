{stdenv, fetchurl, libgphoto2, fuse, pkgconfig, glib, libtool}:
let
  s = # Generated upstream information
  rec {
    baseName="gphoto2fs";
    version="0.5";
    name="${baseName}-${version}";
    hash="04slwhr6ap9xcc27wphk22ad8yn79ngyy5z10lxams3k5liahvc2";
    url="mirror://sourceforge/project/gphoto/gphotofs/0.5.0/gphotofs-0.5.tar.gz";
    sha256="04slwhr6ap9xcc27wphk22ad8yn79ngyy5z10lxams3k5liahvc2";
  };
  buildInputs = [
    libgphoto2 fuse pkgconfig glib libtool
  ];
in
stdenv.mkDerivation {
  inherit (s) name version;
  inherit buildInputs;
  src = fetchurl {
    inherit (s) url sha256;
  };
  meta = {
    inherit (s) version;
    description =  "Fuse FS to mount a digital camera";
    license = stdenv.lib.licenses.gpl2;
    maintainers = [stdenv.lib.maintainers.raskin];
    platforms = stdenv.lib.platforms.linux;
  };
}
