Function Get-NAVDockerContainerCredentials
{
    $credPath = Join-Path $env:LOCALAPPDATA "AdvaniaGIT"
    $credFileName = "DockerSettings.json"
    if (Test-Path (Join-Path $credPath $credFileName)) {
        $cred = Get-Content -Encoding UTF8 -Path (Join-Path $credPath $credFileName) | ConvertFrom-Json
        $Credential = New-Object System.Management.Automation.PSCredential($cred.Username, (ConvertTo-SecureString $cred.Password))
        return $Credential
    }
}