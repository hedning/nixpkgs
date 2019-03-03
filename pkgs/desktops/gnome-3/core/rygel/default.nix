{ stdenv, fetchurl, pkgconfig, vala, gettext, libxml2, gobject-introspection, gtk-doc, wrapGAppsHook, glib, gssdp, gupnp, gupnp-av, gupnp-dlna, gst_all_1, libgee, libsoup, gtk3, libmediaart, sqlite, systemd, tracker, shared-mime-info, gnome3 }:

let
  pname = "rygel";
  version = "0.37.2";
in stdenv.mkDerivation rec {
  name = "${pname}-${version}";

  # TODO: split out lib
  outputs = [ "out" "dev" "devdoc" ];

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${stdenv.lib.versions.majorMinor version}/${name}.tar.xz";
    sha256 = "0f4rxri9vqwrz2scir0pjsg4ilqyclypaakr3x7804g6rkln0q40";
  };

  nativeBuildInputs = [
    pkgconfig vala gettext libxml2 gobject-introspection gtk-doc wrapGAppsHook
  ];
  buildInputs = [
    glib gssdp gupnp gupnp-av gupnp-dlna libgee libsoup gtk3 libmediaart sqlite systemd tracker shared-mime-info
  ] ++ (with gst_all_1; [
    gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly
  ]);

  configureFlags = [
    "--with-systemduserunitdir=$(out)/lib/systemd/user"
    "--enable-apidocs"
    "--sysconfdir=/etc"
  ];

  installFlags = [
    "sysconfdir=$(out)/etc"
  ];

  doCheck = true;

  enableParallelBuilding = true;

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = pname;
      attrPath = "gnome3.${pname}";
    };
  };

  meta = with stdenv.lib; {
    description = "A home media solution (UPnP AV MediaServer) that allows you to easily share audio, video and pictures to other devices";
    homepage = https://wiki.gnome.org/Projects/Rygel;
    license = licenses.lgpl21Plus;
    maintainers = gnome3.maintainers;
    platforms = platforms.linux;
  };
}
