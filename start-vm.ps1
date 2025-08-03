# although this script is silly in itself
# it controls starting the vms in order of their numbering
# better than the command `Start-VM "ubuntu-[1-9]"`
#
# Example call:
#   .\start-vm.ps1 1 6


for (($X=$args[0]); $X -le $args[1]; $X++) {
  Start-VM ubuntu-$X
}
