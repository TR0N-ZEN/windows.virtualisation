$VM_NAME_REGEX = ([string]::Concat("ubuntu-[", $args[0], "]"))
$SWITCH_NAME = $args[1]

Get-VMNetworkAdapter -VMName $VM_NAME_REGEX | `
  Where-Object SwitchName -eq $SWITCH_NAME | `
  Remove-VMNetworkAdapter

#Write-Host 'Network adapters connected to each VM matching the regex stored:'
#Get-VMNetworkAdapter $VM_NAME_REGEX

Write-Host ''

Write-Host 'Network adapters still connected to the switch:' 
Get-VMNetworkAdapter -VMName * | `
  Where-Object SwitchName -eq $SWITCH_NAME | `
  Select-Object -Property VMName, MacAddress | `
  Sort-Object -Property VMName | `
  Format-Table

Remove-VMSwitch $SWITCH_NAME && Get-NetNat $SWITCH_NAME | Remove-NetNat
  # first command fails if at least VM is connected to it
  # second command fails if there was not NAT activated for the given switch
  #   which e.g. is the case if the switch was of type "Private"
