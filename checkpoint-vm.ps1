# Example call:
#   .\checkpoint-vm.ps1 "1-6" "individualized"

Get-VM ([string]::Concat("ubuntu-[", $args[0], "]")) | `
Checkpoint-VM -SnapshotName ([string]$args[1])
