# Example call:
#   .\ssh-into-vm.ps1 "1-6"
#   .\ssh-into-vm.ps1 "1-6" "switch_internal"

$SWITCH_NAME = $args[1] ?? "Default Switch"

$CRED = Get-Credential ([Environment]::GetEnvironmentVariable("USERNAME"))

$IF_IDX = Get-NetAdapter ([string]::Concat("vEthernet (", $SWITCH_NAME, ")")) | Select-Object -ExpandProperty ifIndex

$MAC_ADDRESSES = Get-VM ([string]::Concat("ubuntu-[", $args[0], "]")) |
  Get-VMNetworkAdapter |
  Where-Object SwitchName -eq $SWITCH_NAME |
  Sort-Object VMName |
  Select-Object -ExpandProperty MacAddress

foreach ($MAC_ADDRESS in $MAC_ADDRESSES) {
  # Write-Host $MAC_ADDRESS

  # The bits 5th,6th,7th and 8th bit (second half byte) from
  #   the left of the mac address
  $SECOND_HALFBYTE = [int]("0x" + $MAC_ADDRESS[1])

  $SECOND_HALFBYTE = $SECOND_HALFBYTE -bxor 0b0010

  $LINKLOCALE_IPv6_ADDRESS = [string]::Format('FE80::{0}:{1}:{2}:{3}',
    [string]::Concat(
      $MAC_ADDRESS[0], [string]$SECOND_HALFBYTE, $MAC_ADDRESS.substring(2,2)),
    $MAC_ADDRESS.substring(4,2)+"FF",
    "FE"+$MAC_ADDRESS.substring(6,2),
    $MAC_ADDRESS.substring(8,4))
  Write-Host $LINKLOCALE_IPv6_ADDRESS

  Start-Process powershell `
    -ArgumentList "-NoExit", "-Command", "if (Test-Connection [$LINKLOCALE_IPv6_ADDRESS%$IF_IDX] -Quiet) { ssh tony@[$LINKLOCALE_IPv6_ADDRESS%$IF_IDX] }" `
    -Credential $CRED `
    -UseNewEnvironment
}

# to get the ipv4 addresses of the vms use the following
#
#  Start-Process powershell `
#    -ArgumentList "-NoExit", "-Command", "ssh tony@$LINKLOCALE_IPv6_ADDRESS 'ip -4 -json address show dev eth0 scope global | jq .[0].addr_info[0].local'" `
#    -Credential $CRED `
#    -UseNewEnvironment
