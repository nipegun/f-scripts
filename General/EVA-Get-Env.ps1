EVA-Discover.ps1

Write-Output ""
Write-Output "Showing environment info:"
Write-Output ""
EVA-FTP-Client.ps1 -Verbose -ScriptBlock { GetEnvironmentValue env }

Write-Output ""
Write-Output "If you want to reboot now, run:"
Write-Output "EVA-Reboot.ps1"
Write-Output "or wait a minute or two and the Fritz!Box will reboot by itself"
Write-Output ""

