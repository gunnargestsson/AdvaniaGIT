Function Set-NAVDockerContainerCredentials
{

    $Credential = Get-Credential -Message "Set Docker Container Credentials" -UserName $env:USERNAME -ErrorAction Stop  

    $cred = New-Object -TypeName PSObject
    $cred | Add-Member -MemberType NoteProperty -Name Username -Value $Credential.UserName
    $cred | Add-Member -MemberType NoteProperty -Name Password -Value (ConvertFrom-SecureString -SecureString $Credential.Password)
    
    $credPath = Join-Path $env:LOCALAPPDATA "AdvaniaGIT"
    New-Item -Path $credPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    $credFileName = "DockerSettings.json"
    Set-Content -Value ($cred | ConvertTo-Json) -Encoding UTF8 -Path (Join-Path $credPath $credFileName)
}
