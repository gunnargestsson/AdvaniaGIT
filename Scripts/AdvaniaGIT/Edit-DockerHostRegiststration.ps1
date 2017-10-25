Function Edit-DockerHostRegiststration
{
    param(
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$RemoveHostName,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$AddHostName,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$AddIpAddress
    )

    $hostsPath = Get-Item -Path (Join-Path $env:SystemRoot "System32\Drivers\etc\hosts")
    $newHostsContent = @()
    if ($hostsPath.Length -eq 0) {
        $newHostsContent += "127.0.0.1 localhost"
    }     
    if ($hostsPath.Length -gt 0) {
        $hostsContent = Get-Content -Path $hostsPath -Encoding Ascii
        foreach ($hostsLine in $hostsContent) {
            if ($RemoveHostName -ne $null -and $RemoveHostName -gt "" -and $hostsLine -imatch $RemoveHostName) {
              Write-Verbose "Removing ${hostsLine}..."
            } elseif ($hostsLine -gt "") {
                $newHostsContent += $hostsLine 
            }
        }
    }
    if ($AddHostName -ne $null -and $AddIpAddress -ne $null) {
        $newHostsContent += "${AddIpAddress}    ${AddHostName}" + "`r`n"
    }
    if ($newHostsContent.Length -gt 0) {
        Set-Content -Encoding Ascii -Path $hostsPath -Value $newHostsContent 
    }
}
