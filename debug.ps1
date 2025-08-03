Start-Process powershell `
-Verb RunAsUser `
-ArgumentList "-NoExit", "-Command", "ssh tony@$LINKLOCALE_IPv6_ADDRESS"

#([Environment]::GetEnvironmentVariable("USERNAME"))
