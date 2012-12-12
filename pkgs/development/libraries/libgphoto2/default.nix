{stdenv, fetchurl, pkgconfig, libtool, libexif, libjpeg, gettext
, libusb, libusb_0_1}:

stdenv.mkDerivation rec {
  name = "libgphoto2-${meta.version}";

  src = fetchurl {
    url = "mirror://sourceforge/project/gphoto/libgphoto/2.5.0/libgphoto2-2.5.0.tar.gz";
    sha256 = "0mszhlq5knwqlf5ya9qgvlgm4xqq000mcpkpjjbdx3amivrxyjzc";
  };
  
  buildNativeInputs = [ pkgconfig gettext ];
  buildInputs = [ libtool libjpeg ];

  # These are mentioned in the Requires line of libgphoto's pkg-config file.
  propagatedBuildInputs = [ libusb libusb_0_1 libexif ];

  meta = {
    version = "2.5.0";
    homepage = http://www.gphoto.org/proj/libgphoto2/;
    description = "A library for accessing digital cameras";
    longDescription = ''
      This is the library backend for gphoto2. It contains the code for PTP,
      MTP, and other vendor specific protocols for controlling and transferring data
      from digital cameras. 
    '';
    # XXX: the homepage claims LGPL, but several src files are lgpl21Plus
    license = stdenv.lib.licenses.lgpl21Plus; 
    platforms = with stdenv.lib.platforms; unix;
    maintainers = with stdenv.lib.maintainers; [ jcumming raskin ];
  };
}
