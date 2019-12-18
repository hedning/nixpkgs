{ fetchurl
, stdenv
, meson
, ninja
, pkgconfig
, gnome3
, gtk3
, atk
, gobject-introspection
, spidermonkey_68
, pango
, cairo
, readline
, glib
, libxml2
, dbus
, gdk-pixbuf
, makeWrapper
, nixosTests
, fetchpatch
}:

stdenv.mkDerivation rec {
  pname = "gjs";
  version = "1.63.92";

  src = fetchurl {
    url = "mirror://gnome/sources/gjs/${stdenv.lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "11w5g7s4654m5cm29m11s2cmcpa602j6ihhjp0r80fxf3g6l51vd";
  };

  outputs = [ "out" "dev" "installedTests" ];

  nativeBuildInputs = [
    meson
    ninja
    pkgconfig
    makeWrapper
    libxml2 # for xml-stripblanks
  ];

  buildInputs = [
    gobject-introspection
    cairo
    readline
    spidermonkey_68
    dbus # for dbus-run-session
  ];

  propagatedBuildInputs = [
    glib
  ];

  mesonFlags = [
    "-Dprofiler=disabled"
  ];

  patches = [
    (fetchpatch {
      # https://gitlab.gnome.org/GNOME/gjs/-/merge_requests/396
      url = "https://gitlab.gnome.org/GNOME/gjs/-/commit/76739db6803ed01d6ef31de6aaaf3689d31c2c9e.patch";
      sha256 = "1jakil88qvnlwrxfjg96fqq9kl0kzqj7k3x7argfpmhj6lsggfhy";
    })
    (fetchpatch {
      # https://gitlab.gnome.org/GNOME/gjs/-/merge_requests/396
      url = "https://gitlab.gnome.org/GNOME/gjs/-/commit/f4b3fc00e681c472a5dc7c962a13317e355dc5ea.patch";
      sha256 = "0vdfqyz5g8byp3x65ymi7l49m5ip6czbddnp97rj6s7ax3gj307n";
    })
    (fetchpatch {
      # https://gitlab.gnome.org/GNOME/gjs/-/merge_requests/396
      url = "https://gitlab.gnome.org/GNOME/gjs/-/commit/b77830b36efc2b837681dc9f5053136c77282ba8.patch";
      sha256 = "1yhl4yxm5yrdljnp4w93nhij5fasv5l47glklj722x463z9mjziq";
    })
  ];

  # configureFlags = [
  #   "--enable-installed-tests"
  # ];

  postPatch = ''
    for f in installed-tests/*.test.in; do
      substituteInPlace "$f" --subst-var-by pkglibexecdir "$installedTests/libexec/gjs"
    done
  '';

  postInstall = ''
    moveToOutput "share/installed-tests" "$installedTests"
    moveToOutput "libexec/gjs/installed-tests" "$installedTests"

    wrapProgram "$installedTests/libexec/gjs/installed-tests/minijasmine" \
      --prefix GI_TYPELIB_PATH : "${stdenv.lib.makeSearchPath "lib/girepository-1.0" [ gtk3 atk pango.out gdk-pixbuf ]}:$installedTests/libexec/gjs/installed-tests"
  '';

  separateDebugInfo = stdenv.isLinux;

  passthru = {
    tests = {
      installed-tests = nixosTests.installed-tests.gjs;
    };

    updateScript = gnome3.updateScript {
      packageName = "gjs";
    };
  };

  meta = with stdenv.lib; {
    description = "JavaScript bindings for GNOME";
    homepage = "https://gitlab.gnome.org/GNOME/gjs/blob/master/doc/Home.md";
    license = licenses.lgpl2Plus;
    maintainers = gnome3.maintainers;
    platforms = platforms.linux;
  };
}
