{stdenv, fetchurl
  , tcsh, ArchiveZip, cups, pam, jdk, gperf, freetype, gtk2, libIDL, libXaw
  , bison, patch, GConf, gnome_vfs, ant, flex, libxslt, openldap, libX11
  , xproto, gstreamer, gst_plugins_base, db4, unixODBC, boost, expat
  , python, curl, fontconfig, libXrandr, randrproto, ORBit2, libxml2, neon
  , libwpd, libwpg, icu, hunspell, saxon, vigra, xsane, xulrunner
  }:

stdenv.mkDerivation rec {
  version = "3.4.1";
  name = "apache-openoffice-${version}";

  src = fetchurl {
    url = "http://www.apache.org/dyn/aoo-closer.cgi/incubator/ooo/${version}/source/aoo-${version}-incubating-src.tar.bz2";
    sha256 = "671709ad67671a0f8ae668596b5786d572fac7bf4ff67ae488e5f59338ca854b";
  };

  buildInputs = [
    # Fedora instruction 1
    tcsh ArchiveZip cups pam jdk gperf freetype gtk2 libIDL libXaw
    bison patch GConf gnome_vfs ant
    # Fedora instruction 2 - mono skipped
    flex libxslt openldap libX11 xproto gstreamer gst_plugins_base
    db4 unixODBC boost expat python curl
    # Ubuntu instruction - junit skipped
    fontconfig libXrandr randrproto ORBit2
    # OpenSUSE instruction
    libxml2 neon libwpd libwpg icu hunspell
    # Gentoo instruction
    saxon vigra xsane
    # Mozilla libraries
    xulrunner
    ];

  preConfigure = ''
    export NIX_LDFLAGS="$NIX_LDFLAGS -L${xulrunner}/lib/xulrunner-${xulrunner.version}"
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I${xulrunner}/include/xulrunner-${xulrunner.version}"
  '';

  configureFlags = [
    "--without-junit"
    "--with-system-libs"
    "--with-system-headers"
  ];

  meta = {
    description = ''Apache continuation of OpenOffice.org office suite'';
    platforms = with stdenv.lib.platforms; linux;
    maintainers = with stdenv.lib.maintainers; [raskin];
  };
}
