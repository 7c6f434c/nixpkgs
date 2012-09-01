{stdenv, fetchurl, xorg, automake, autoconf, libtool, pkgconfig, perl, makeOverridable}:
{
  xf86videoati = {src, suffix}: 
  makeOverridable stdenv.mkDerivation {
      name = "xf86-video-ati-${suffix}";
      buildInputs = xorg.xf86videoati.buildInputs ++
         [autoconf automake libtool];
      builder = ./builder.sh;
      inherit src;
      preConfigure = ''
        export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -DPACKAGE_VERSION_MAJOR=6"
        export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -DPACKAGE_VERSION_MINOR=9"
        export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -DPACKAGE_VERSION_PATCHLEVEL=999"

        sed -e 's/@DRIVER_MAN_SUFFIX@/man/g' -i man/Makefile.am
        export DRIVER_MAN_DIR=$out/share/man/man5 

        ./autogen.sh
      '';
  };

  pixman_0_26 = (stdenv.mkDerivation ({
    name = "pixman-0.26.2";
    builder = ./builder.sh;
    src = fetchurl {
      url = mirror://xorg/individual/lib/pixman-0.26.2.tar.bz2;
      sha256 = "0z34jb75wpbyj3gxn34icd8j81fk5d6s6qnwp2ncz7m8icf6afqr";
    };
    buildInputs = [pkgconfig ];
    buildNativeInputs = [perl ];
  })) // {inherit perl ;};
}
