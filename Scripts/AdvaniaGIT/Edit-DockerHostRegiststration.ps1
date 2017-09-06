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

    $hostsPath = Join-Path $env:SystemRoot "System32\Drivers\etc\hosts"
    $hostsContent = Get-Content -Path $hostsPath -Encoding Ascii
    $newHostsContent = @()
    foreach ($hostsLine in $hostsContent) {
        if ($RemoveHostName -ne $null -and $RemoveHostName -gt "" -and $hostsLine -imatch $RemoveHostName) {
          Write-Verbose "Removing ${hostsLine}..."
        } elseif ($hostsLine -gt "") {
            $newHostsContent += $hostsLine 
        }
    }
    if ($AddHostName -ne $null -and $AddIpAddress -ne $null) {
        $newHostsContent += "${AddIpAddress}    ${AddHostName}" + "`r`n"
    }

    Set-Content -Encoding Ascii -Path $hostsPath -Value $newHostsContent 
}
