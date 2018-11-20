gettextDataDirsHook() {
    # See pkgs/build-support/setup-hooks/role.bash
    getHostRoleEnvHook
    if [ -d "$1/share/gettext" ]; then
        addToSearchPath GETTEXTDATADIRS "$1/share/gettext"
    fi
}

addEnvHooks "$hostOffset" gettextDataDirsHook

# libintl must be listed in load flags on non-Glibc
# it doesn't hurt to have it in Glibc either though
if [ ! -z "@gettextNeedsLdflags@" ]; then
    # See pkgs/build-support/setup-hooks/role.bash
    getHostRole
    export NIX_${role_pre}LDFLAGS+=" -lintl"
fi
