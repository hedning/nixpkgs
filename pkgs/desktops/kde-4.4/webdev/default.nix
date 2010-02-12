{ stdenv, fetchurl, lib, cmake, qt4, perl, libxml2, libxslt, boost
, kdelibs, kdepimlibs, automoc4, phonon}:

stdenv.mkDerivation {
  name = "kdewebdev-4.3.4";
  src = fetchurl {
    url = mirror://kde/stable/4.3.4/src/kdewebdev-4.3.4.tar.bz2;
    sha1 = "697f0557c616497a6f80bbcac472ad6ddd687ae8";
  };
  CMAKE_PREFIX_PATH=kdepimlibs;
  buildInputs = [ cmake qt4 perl libxml2 libxslt boost kdelibs kdepimlibs automoc4 phonon ];
  meta = {
    description = "KDE Web development utilities";
    license = "GPL";
    homepage = http://www.kde.org;
    maintainers = [ lib.maintainers.sander ];
  };
}
