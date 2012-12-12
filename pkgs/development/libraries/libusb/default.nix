{stdenv, fetchurl}:

stdenv.mkDerivation { 
  name = "libusb-1.0.9";

  # On non-linux, we get warnings compiling, and we don't want the
  # build to break.
  patchPhase = ''
    sed -i s/-Werror// Makefile.in
  '';

  src = fetchurl {
    url = "mirror://sourceforge/project/libusb/libusb-1.0/libusb-1.0.9/libusb-1.0.9.tar.bz2";
    sha256 = "16sz34ix6hw2wwl3kqx6rf26fg210iryr68wc439dc065pffw879";
  };
  meta = {
    version = "1.0.9";
    description = "USB access library";
    license = stdenv.lib.licenses.gpl2;
    maintainers = [stdenv.lib.maintainers.raskin];
    platforms = stdenv.lib.platforms.linux;
  };
}
