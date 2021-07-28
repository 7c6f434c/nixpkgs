{ lib, stdenv, fetchFromGitHub, autoreconfHook
, zlib, SDL, readline, libGLU, libGL, libX11 }:

with lib;
stdenv.mkDerivation rec {
  pname = "atari800";
  version = "4.2.0";

  src = fetchFromGitHub {
    owner = "atari800";
    repo = "atari800";
    rev = "ATARI800_${replaceChars ["."] ["_"] version}";
    sha256 = "15l08clqqayi9izrgsz9achan6gl4x57wqsc8mad3yn0xayzz3qy";
  };

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [ zlib SDL readline libGLU libGL libX11 ];

  configureFlags = [
    "--target=default"
    "--with-video=sdl"
    "--with-sound=sdl"
    "--with-readline"
    "--with-opengl"
    "--with-x"
    "--enable-riodevice"
  ];

  meta = {
    homepage = "https://atari800.github.io/";
    description = "An Atari 8-bit emulator";
    longDescription = ''
      Atari800 is the emulator of Atari 8-bit computer systems and
      5200 game console for Unix, Linux, Amiga, MS-DOS, Atari
      TT/Falcon, MS-Windows, MS WinCE, Sega Dreamcast, Android and
      other systems supported by the SDL library.
    '';
    maintainers = [ maintainers.AndersonTorres ];
    license = licenses.gpl2Plus;
    platforms = lib.platforms.linux;
  };
}
