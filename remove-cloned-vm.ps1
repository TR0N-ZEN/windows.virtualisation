# Example call:
#   .\remove-cloned-vm.ps1 1 6
#
for (($X=$args[0]); $X -le $args[1]; $X++) {
  Stop-VM ubuntu-${X}
  Remove-VM -Force ubuntu-${X}
  rm -r "$HOME\Desktop\hyper-v\VMs\${X}"
  rm -r "$HOME\Desktop\hyper-v\Virtual Hard Disks\${X}"
}
