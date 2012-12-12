{stdenv, fetchurl, pkgconfig, libusb}:

stdenv.mkDerivation { 
  name = "libusb-0.1.4";

  # On non-linux, we get warnings compiling, and we don't want the
  # build to break.
  patchPhase = ''
    sed -i s/-Werror// Makefile.in
  '';

  buildInputs = [ pkgconfig libusb ];

  src = fetchurl {
    url = "mirror://sourceforge/project/libusb/libusb-compat-0.1/libusb-compat-0.1.4/libusb-compat-0.1.4.tar.bz2";
    sha256 = "1i7xm7jx6n6prq18bx9c3rnj4ijg8ldshcdrgxvfy0bv1hbdsnzd";
  };
  meta = {
    version = "0.1.4";
    description = "USB access library - libusb 0.1 compatibility wrapper";
    license = stdenv.lib.licenses.gpl2;
    maintainers = [stdenv.lib.maintainers.raskin];
    platforms = stdenv.lib.platforms.linux;
  };
}
