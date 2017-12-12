$SetupJson = Get-Content $SetupParameters.setupPath -Encoding UTF8 | Out-String | ConvertFrom-Json
$SetupJson | Add-Member -MemberType NoteProperty -Name testExecution -Value "Background" -Force
Set-Content -Value ($SetupJson | ConvertTo-Json) -Encoding UTF8 -Path $SetupParameters.setupPath