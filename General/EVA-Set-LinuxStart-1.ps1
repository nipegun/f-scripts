EVA-Discover.ps1

Write-Output ""
Write-Output "Value of the linux_fs_start environment variable is:"
Write-Output ""
EVA-FTP-Client.ps1 -Verbose -ScriptBlock { GetEnvironmentValue linux_fs_start }

Write-Output ""
Write-Output "Setting value to 1:"
Write-Output ""
EVA-FTP-Client.ps1 -Verbose -ScriptBlock { SetEnvironmentValue linux_fs_start 1}

Write-Output ""
Write-Output "Now value is:"
Write-Output ""
EVA-FTP-Client.ps1 -Verbose -ScriptBlock { GetEnvironmentValue linux_fs_start }

Write-Output ""
Write-Output "If you want to reboot now, run:"
Write-Output "EVA-Reboot.ps1"
Write-Output "or wait a minute or two and the Fritz!Box will reboot by itself"
Write-Output ""

