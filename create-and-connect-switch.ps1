# Example call:
#   .\create-and-connect-switch.ps1 "0-6" "switch_private" "Private"
#   .\create-and-connect-switch.ps1 "1-6" "switch_internal" "Internal" "192.168.2.1" 24
#   .\create-and-connect-switch.ps1 "1-6" "switch_internal" "Internal"
#   .\create-and-connect-switch.ps1 "1-6" "Default Switch"

$VM_NAME_REGEX = ([string]::Concat("ubuntu-[", $args[0], "]"))
$SWITCH_NAME = $args[1]
$SWITCH_TYPE = $args[2]
$NAT_GATEWAY_IP = ($args[3] ?? "192.168.2.1")
$NAT_SUBNET_PREFIX_LENGTH = ($args[4] ?? 24)

foreach ($arg in $args) { Write-Host "$arg" }

if ($SWITCH_NAME -ne "Default Switch") {
  New-VMSwitch -Name $SWITCH_NAME -SwitchType $SWITCH_TYPE | Out-Null
}

if ($SWITCH_TYPE -eq "Internal") {
  [Int]$IF_IDX = Get-NetAdapter ([string]::Concat('vEthernet (',$SWITCH_NAME,')')) | Select-Object -ExpandProperty ifIndex || exit

  $SEQUENCE =  @(0,0,0,0)
  $COUNT = [System.Int32]$NAT_SUBNET_PREFIX_LENGTH
  for($i = 0; $i -lt 4; $i++) {
    $SEQUENCE[$i] = [System.Int32]($COUNT -ge 8)*8 + `
                    [System.Int32]($COUNT -lt 8)*[System.Int32]($COUNT -ge 0)*$COUNT
    $COUNT = $COUNT - 8
  }

  $MASK_BYTES = [System.Byte[]]::new(4)
  $SUBNET_LENGTH = [System.Int32]$NAT_SUBNET_PREFIX_LENGTH

  for($i = 0; $i -lt 4; $i++) {
    $POWER = $SEQUENCE[$I]
    $MASK_BYTES[$i]  =  [System.Byte]([System.Int32]($POWER -gt 7)*255 + `
                                      [System.Int32]($POWER -lt 8)*((([math]::Pow(2,${POWER}))-1) -shl (8-$POWER)))
    #Write-Host $MASK_BYTES[$i]
  }

  $IPA_STRINGS = $NAT_GATEWAY_IP.split(".")
  $OKTETT_STRINGS = [System.String[]]::new(4)
  for($i = 0; $i -lt 4; $i++) {
    $IPA_BYTE = [System.Byte]([System.Int32]::parse($IPA_STRINGS[$i]))
    $OKTETT_STRINGS[$i] = [System.String]([System.Int32]($IPA_BYTE -band $MASK_BYTES[$i]))
    #Write-Host $OKTETT_STRINGS[$i]
  }
  $NAT_SUBNET_ADDRESS = $OKTETT_STRINGS -join "."

  Write-Host ([string]::Concat('$IF_IDX=',$IF_IDX))
  Write-Host ([string]::Concat('$NAT_GATEWAY_IP=',$NAT_GATEWAY_IP))
  Write-Host ([string]::Concat('$NAT_SUBNET_ADDRESS=',$NAT_SUBNET_ADDRESS))

  New-NetIPAddress `
    -IPAddress $NAT_GATEWAY_IP `
    -PrefixLength $NAT_SUBNET_PREFIX_LENGTH `
    -InterfaceIndex $IF_IDX `
  | Out-Null

  New-NetNat `
    -Name $SWITCH_NAME `
    -InternalIPInterfaceAddressPrefix "${NAT_SUBNET_ADDRESS}/${NAT_SUBNET_PREFIX_LENGTH}" `
  | Out-Null
}

$VM_NAMES = Get-VM $VM_NAME_REGEX | `
  Sort-Object VMName | `
  Select-Object -ExpandProperty VMName

foreach ($VM_NAME in $VM_NAMES) {
  # TODO fix crash if two switches have the same name
  Add-VMNetworkAdapter -VMName $VM_NAME -SwitchName $SWITCH_NAME | Out-Null
}

Write-Host 'VMs and mac addresses of the NICs connected to the new switch:'
Get-VMNetworkAdapter $VM_NAME_REGEX | `
  Where-Object SwitchName -eq $SWITCH_NAME | `
  Select-Object -Property VMName, MacAddress | `
  Sort-Object -Property VMName | `
  Format-Table
