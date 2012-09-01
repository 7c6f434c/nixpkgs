{ stdenv, fetchurl, glib, libxml2, pkgconfig
, gnomeSupport ? true, libgnome_keyring, sqlite, glib_networking }:

stdenv.mkDerivation rec {
  name = "libsoup-2.38.1";

  src = fetchurl {
    url = "mirror://gnome/sources/libsoup/2.38/${name}.tar.xz";
    sha256 = "71b8923fc7a5fef9abc5420f7f3d666fdb589f43a8c50892d584d58b3c513f9a";
  };


  buildNativeInputs = [ pkgconfig ];
  propagatedBuildInputs = [ glib libxml2 ]
    ++ stdenv.lib.optionals gnomeSupport [ libgnome_keyring sqlite ];
  passthru.propagatedUserEnvPackages = [ glib_networking ];

  # glib_networking is a runtime dependency, not a compile-time dependency
  configureFlags = "--disable-tls-check";

  meta = {
    inherit (glib.meta) maintainers platforms;
  };
}
