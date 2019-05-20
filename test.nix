{
  pkgs ? import <nixpkgs> {}
}:
let
  holey = "${import ./default.nix {inherit (pkgs);}}/bin/holey";
  fallocate = "${pkgs.utillinux}/bin/fallocate";
  fdisk = "${pkgs.utillinux}/bin/fdisk";
  script = ''
    PS4=" $ "
    set -x
    ${holey} help
    ${fallocate} -l 2G disk.img
    ${holey} disk.img init
    ${holey} disk.img add esp 256
    ${holey} disk.img add linux

    ${holey} disk.img check
    ${fdisk} -l disk.img
  '';
in
pkgs.runCommand "log.txt" {} ''
  (
  ${script}
  ) 2>&1 | tee $out
''
