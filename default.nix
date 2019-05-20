{
  pkgs ? import <nixpkgs> {}
}:
let
  inherit (pkgs) runtimeShell runCommand vboot_reference writeScript;
  inherit (pkgs.lib) makeBinPath;
  version = "0.1.0";
  wrapper = writeScript "holey-wrapper" ''
  #!${runtimeShell}
  PATH="${makeBinPath [vboot_reference]}:$PATH"
  exec ${runtimeShell} @HOLEY@ "$@"
  '';
in
  runCommand "holey-gpt-${version}" {} ''
  mkdir -pv $out/{bin,libexec}
  cp ${wrapper} $out/bin/holey
  substituteInPlace $out/bin/holey \
    --replace @HOLEY@ $out/libexec/holey
  cp ${./holey} $out/libexec/holey
  ''
