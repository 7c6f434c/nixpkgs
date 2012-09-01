{ stdenv, fetchurl, glib, flex, bison, pkgconfig, libffi, python, xz }:

let
  baseName = "gobject-introspection";
  v = "1.32.1";
in

stdenv.mkDerivation rec {
  name = "${baseName}-${v}";

  buildInputs = [ flex bison glib pkgconfig python ];
  propagatedBuildInputs = [ libffi ];
  buildNativeInputs = [xz];

  # Tests depend on cairo, which is undesirable (it pulls in lots of
  # other dependencies).
  configureFlags = "--disable-tests";

  src = fetchurl {
    url = "mirror://gnome/sources/${baseName}/1.32/${name}.tar.xz";
    sha256 = "44f3fb933f76e4728818cc360cb5f9e2edcbdf9bc8a8f9aded99b3e3ef5cb858";
  };

  postInstall = "rm -rf $out/share/gtk-doc";

  meta = with stdenv.lib; {
    maintainers = [ maintainers.urkud ];
    platforms = platforms.linux;
    homepage = http://live.gnome.org/GObjectIntrospection;
  };
}
