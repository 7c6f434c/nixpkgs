{stdenv, fetchurl, pkgconfig, glib }:

stdenv.mkDerivation rec {
  name = "liboil-0.3.17";

  src = fetchurl {
    url = "${meta.homepage}/download/${name}.tar.gz";
    sha256 = "105f02079b0b50034c759db34b473ecb5704ffa20a5486b60a8b7698128bfc69";
  };

  buildInputs = [pkgconfig glib];

  meta = {
    homepage = http://liboil.freedesktop.org;
    description = "A library of simple functions that are optimized for various CPUs";
  };
}
