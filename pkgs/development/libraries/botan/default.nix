{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  baseVersion = "1.11";
  revision = "34";
  sha256 = "sha256:05hzffp0dxac7414a84z0fgv980cnfx55ch2y4vpg5nvin7m9bar";
  postPatch = ''
    sed -e 's@lang_flags "@&--std=c++11 @' -i src/build-data/cc/{gcc,clang}.txt
    sed -e '1i#include <functional>' -i src/lib/filters/threaded_fork.cpp
  '';
})
