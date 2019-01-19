{ callPackage, runCommand, writeScript, stdenv, coreutils }:

args@{ name, runScript ? if hostShell then "$SHELL" else "bash"
, extraInstallCommands ? "", meta ? {}, passthru ? {}
# Don't reset the path, only prepend to it
, inheritPath ? true
# Run $SHELL instead of bash, also use the host's regular shell config
, hostShell ? true, ... }:

let

  buildFHSEnv = callPackage ./env.nix {};

  env = buildFHSEnv (removeAttrs args [ "runScript" "extraInstallCommands" "meta" "passthru" ]);

  chrootenv = callPackage ./chrootenv {};

  init = run: writeScript "${name}-init" ''
    #! ${stdenv.shell}
    for i in ${env}/* /host/*; do
      path="/''${i##*/}"
      [ -e "$path" ] || ${coreutils}/bin/ln -s "$i" "$path"
    done

    [ -d "$1" ] && [ -r "$1" ] && cd "$1"
    shift

    source /etc/chroot-profile
    exec ${run} "$@"
  '';

in runCommand name {
  inherit meta;
  passthru = passthru // {
    env = runCommand "${name}-shell-env" {
      shellHook = ''
        exec ${chrootenv}/bin/chrootenv ${init runScript} "$(pwd)"
      '';
    } ''
      echo >&2 ""
      echo >&2 "*** User chroot 'env' attributes are intended for interactive nix-shell sessions, not for building! ***"
      echo >&2 ""
      exit 1
    '';
  };
} ''
  mkdir -p $out/bin
  cat <<EOF >$out/bin/${name}
  #! ${stdenv.shell}
  exec ${chrootenv}/bin/chrootenv ${init runScript} "\$(pwd)" "\$@"
  EOF
  chmod +x $out/bin/${name}
  ${extraInstallCommands}
''
