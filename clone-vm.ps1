# Example call:
#   .\clone-vm.ps1 PROTOTYPE 1 6

$COPY_SOURCE = $args[0]

mkdir "$HOME\Desktop\hyper-v\exported"

for (($X=$args[1]); $X -le ($args[2] ?? $args[1]); $X++) {
  mkdir "$HOME\Desktop\hyper-v\VMs\${X}\"
  mkdir "$HOME\Desktop\hyper-v\Virtual Hard Disks\${X}"
}


Export-VM -Name ubuntu-${COPY_SOURCE} -Path "$HOME\Desktop\hyper-v\exported"


$FILE_NAME = Get-ChildItem "$HOME\Desktop\hyper-v\exported\ubuntu-${COPY_SOURCE}\Virtual Machines\" -Name *.vmcx
Write-Host $FILE_NAME


for (($NUMBER=$args[1]); $NUMBER -le ($args[2] ?? $args[1]); $NUMBER++) {
  $IMPORTED_VM = Import-VM `
-Path "$HOME\Desktop\hyper-v\exported\ubuntu-${COPY_SOURCE}\Virtual Machines\$FILE_NAME" `
-Copy `
-VirtualMachinePath "$HOME\Desktop\hyper-v\VMs\${NUMBER}\" `
-SnapshotFilePath "$HOME\Desktop\hyper-v\VMs\${NUMBER}" `
-SmartPagingFilePath "$HOME\Desktop\hyper-v\VMs\${NUMBER}" `
-VhdDestinationPath "$HOME\Desktop\hyper-v\Virtual Hard Disks\${NUMBER}" `
-GenerateNewId
  
  $IMPORTED_VM | Rename-VM -NewName ubuntu-${NUMBER}
}

rm -r "$HOME\Desktop\hyper-v\exported\ubuntu-${COPY_SOURCE}"

# sources:
#   1. https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/deploy/export-and-import-virtual-machines?tabs=powershell
