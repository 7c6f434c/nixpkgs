{ lib, stdenv, fetchFromGitHub, zlib, autoreconfHook, pkg-config, perl }:

stdenv.mkDerivation rec {
  pname = "vcftools";
  version = "0.1.16";

  src = fetchFromGitHub {
    repo = pname;
    owner = "vcftools";
    rev = "v${version}";
    sha256 = "0msb09d2cnm8rlpg8bsc1lhjddvp3kf3i9dsj1qs4qgsdlzhxkyx";
  };

  buildInputs = [ autoreconfHook pkg-config zlib perl ];

  meta = with lib; {
    description = "A set of tools written in Perl and C++ for working with VCF files, such as those generated by the 1000 Genomes Project";
    license = licenses.lgpl3;
    platforms = platforms.linux;
    homepage = "https://vcftools.github.io/index.html";
    maintainers = [ maintainers.rybern ];
  };
}
