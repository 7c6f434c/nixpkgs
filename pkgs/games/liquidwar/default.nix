{
  lib,
  stdenv,
  fetchurl,
  xorgproto,
  libX11,
  libXrender,
  gmp,
  libjpeg,
  libpng,
  expat,
  gettext,
  perl,
  guile,
  boehmgc,
  SDL,
  SDL_image,
  SDL_mixer,
  SDL_ttf,
  curl,
  sqlite,
  libtool,
  readline,
  libogg,
  libvorbis,
  libcaca,
  csound,
  cunit,
  pkg-config,
  runCommand,
}:

let
  fake_guile_2_0 = runCommand "fake-guile-2.0" { } ''
    mkdir -p "$out"/{bin,lib,include/guile}
    ln -s "${lib.getBin guile}"/bin/guile* "$out"/bin
    ln -s "${lib.getLib guile}"/lib/lib* "$out"/lib
    ln -s "${lib.getLib guile}"/lib/libguile-?.?.so "$out"/lib/libguile-2.0.so
    ln -s "${lib.getLib guile}"/lib/libguile-?.?.so "$out"/lib/libguile.so
    ln -s "${lib.getDev guile}"/include/guile/* "$out/include/guile/2.0"
    ln -s "${lib.getDev guile}"/include/guile/* "$out/include/guile/"
    ln -s "${lib.getDev guile}"/include/guile/*/* "$out/include/"
  '';
in

stdenv.mkDerivation rec {
  pname = "liquidwar6";
  version = "0.6.3902";

  src = fetchurl {
    url = "mirror://gnu/liquidwar6/${pname}-${version}.tar.gz";
    sha256 = "1976nnl83d8wspjhb5d5ivdvdxgb8lp34wp54jal60z4zad581fn";
  };

  postPatch = ''
    sed -e 's/\<SCM_LIST0/SCM_EOL/g' -i src/lib/lw6*.c
  '';

  buildInputs = [
    xorgproto
    libX11
    gmp
    fake_guile_2_0
    boehmgc
    libjpeg
    libpng
    expat
    gettext
    perl
    SDL
    SDL_image
    SDL_mixer
    SDL_ttf
    curl
    sqlite
    libogg
    libvorbis
    csound
    libXrender
    libcaca
    cunit
    libtool
    readline
  ];

  nativeBuildInputs = [ pkg-config ];

  hardeningDisable = [ "format" ];

  env.NIX_CFLAGS_COMPILE = toString (
    lib.optionals (stdenv.cc.isGNU && lib.versionAtLeast stdenv.cc.version "12") [
      # Needed with GCC 12 but problematic with some old GCCs
      "-Wno-error=address"
      "-Wno-error=use-after-free"
      "-std=gnu17"
    ]
    ++ [
      "-Wno-error=deprecated-declarations"
      # Avoid GL_GLEXT_VERSION double definition
      " -DNO_SDL_GLEXT"
    ]
  );

  # To avoid problems finding SDL_types.h.
  configureFlags = [ "CFLAGS=-I${lib.getDev SDL}/include/SDL" ];

  meta = {
    description = "Quick tactics game";
    homepage = "https://www.gnu.org/software/liquidwar6/";
    maintainers = [ lib.maintainers.raskin ];
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
  };
}
