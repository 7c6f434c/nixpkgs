{stdenv, fetchurl, pkgconfig, glib, libtool, intltool, gnutls2, libproxy
, gsettings_desktop_schemas, libgcrypt, libtasn1 }:

stdenv.mkDerivation rec {
  name = "glib-networking-2.32.3";

  src = fetchurl {
    url = "mirror://gnome/sources/glib-networking/2.32/${name}.tar.xz";
    sha256 = "39fe23e86a57bb7a8a67c65668394ad0fbe2d43960c1f9d68311d5d13ef1e5cf";
  };

  configureFlags = "--with-ca-certificates=/etc/ca-bundle.crt";
  
  preBuild = ''
    sed -e "s@${glib}/lib/gio/modules@$out/lib/gio/modules@g" -i $(find . -name Makefile)
  '';

  buildNativeInputs = [ pkgconfig intltool ];
  propagatedBuildInputs =
    [ glib libtool gnutls2 libproxy libgcrypt libtasn1 gsettings_desktop_schemas ];
}
