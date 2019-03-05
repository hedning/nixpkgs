{ stdenv
, meson
, ninja
, fetchurl
, pkgconfig
, gobject-introspection
, vala
, gtk-doc
, docbook_xsl
, docbook_xml_dtd_412
, libsoup
, gtk3
, glib }:

stdenv.mkDerivation rec {
  name = "gssdp-${version}";
  version = "1.1.3";

  outputs = [ "out" "bin" "dev" "devdoc" ];

  src = fetchurl {
    url = "mirror://gnome/sources/gssdp/${stdenv.lib.versions.majorMinor version}/${name}.tar.xz";
    sha256 = "1x9cvadnvwb7zlzsa1xlj0vpnk7cbnzvgpa9xp06bws99xw5sly9";
  };

  nativeBuildInputs = [
    meson ninja
    pkgconfig gobject-introspection vala gtk-doc docbook_xsl
    docbook_xml_dtd_412
  ];
  buildInputs = [ libsoup gtk3 ];
  propagatedBuildInputs = [ glib ];

  mesonFlags = [
    "-Dgtk_doc=true"
  ];

  doCheck = true;

  meta = with stdenv.lib; {
    description = "GObject-based API for handling resource discovery and announcement over SSDP";
    homepage = http://www.gupnp.org/;
    license = licenses.lgpl2Plus;
    platforms = platforms.all;
  };
}
