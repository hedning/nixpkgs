{ stdenv, fetchurl, pkgconfig, gobject-introspection, vala, gtk-doc
, docbook_xsl, docbook_xml_dtd_412, docbook_xml_dtd_44, glib, gssdp, libsoup
, libxml2, libuuid, meson, ninja }:

stdenv.mkDerivation rec {
  name = "gupnp-${version}";
  version = "1.1.2";

  outputs = [ "out" "dev" "devdoc" ];

  src = fetchurl {
    url = "mirror://gnome/sources/gupnp/${stdenv.lib.versions.majorMinor version}/gupnp-${version}.tar.xz";
    sha256 = "04nlhg7si6in2r3lhn9il7drw62m6m1f9ai013m9133ax27pq2ih";
  };

  patches = [
    # Nix’s pkg-config ignores Requires.private
    # https://github.com/NixOS/nixpkgs/commit/1e6622f4d5d500d6e701bd81dd4a22977d10637d
    # We are essentialy reverting the following patch for now
    # https://bugzilla.gnome.org/show_bug.cgi?id=685477
    # at least until Requires.internal or something is implemented
    # https://gitlab.freedesktop.org/pkg-config/pkg-config/issues/7

    # Meson update:
    # Add propagatedBuildInputs to pkg-config Requires field
    ./fix-requires.patch
  ];

  nativeBuildInputs = [
    meson ninja
    pkgconfig gobject-introspection vala gtk-doc docbook_xsl
    docbook_xml_dtd_412 docbook_xml_dtd_44
  ];
  propagatedBuildInputs = [ glib gssdp libsoup libxml2 libuuid ];

  mesonFlags = [
    "-Dgtk_doc=true"
  ];

  doCheck = true;

  meta = with stdenv.lib; {
    homepage = http://www.gupnp.org/;
    description = "An implementation of the UPnP specification";
    license = licenses.lgpl2Plus;
    platforms = platforms.linux;
  };
}
