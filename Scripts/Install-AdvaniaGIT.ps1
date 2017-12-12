Remove-Item -Path "$($env:TEMP)\AdvaniaGIT.zip" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$($env:TEMP)\AdvaniaGIT" -Recurse -Force -ErrorAction SilentlyContinue
Invoke-WebRequest -Uri "https://github.com/gunnargestsson/AdvaniaGIT/archive/master.zip" -OutFile "$($env:TEMP)\AdvaniaGIT.zip" -ErrorAction Stop
Expand-Archive -LiteralPath "$($env:TEMP)\AdvaniaGIT.zip" -DestinationPath "$($env:TEMP)\AdvaniaGIT"
$currentLocation = (Get-Location).Path
Set-Location "$($env:TEMP)\AdvaniaGIT\AdvaniaGIT-master"
try { & .\Installation.ps1 }
catch [Exception] { Write-Host $_.Exception.GetType().FullName, $_.Exception.Message }
Set-Location $currentLocation
if ($env:TERM_PROGRAM -eq $null) { $input = Read-Host -Prompt "Press any key to continue..." }

