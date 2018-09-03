Function Edit-DockerHostRegistration
{
    param(
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$RemoveHostName,
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyname=$true)]
        [String]$AddHostName,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$AddIpAddress
    )

    $hostsPath = Get-Item -Path (Join-Path $env:SystemRoot "System32\Drivers\etc\hosts")
    $hostsContent = $null
    while (!($HostsContent)) {
        try {
            $hostsContent = Get-Content -Path $hostsPath -Encoding Ascii
        } 
        catch {
            Start-Sleep -Seconds 1
        }
    }
    
    $newHostsContent = @()
    foreach ($hostsLine in $hostsContent) {
        if ($RemoveHostName -ne $null -and $RemoveHostName -gt "" -and $hostsLine -imatch $RemoveHostName) {
            Write-Verbose "Removing ${hostsLine} from hosts..."
        } elseif ($hostsLine -gt "") {
            $newHostsContent += $hostsLine 
        }
    }

    
    if ($AddHostName -ne $null -and [bool]($AddIpAddress -as [ipaddress])) {
        Write-Verbose "Adding ${AddHostName} to hosts..."
        $newHostsContent += "${AddIpAddress}    ${AddHostName}" + "`r`n"
    }

    $hostsWritten = $null
    while (!($hostsWritten)) {
        try {
            Remove-Item -Path $hostsPath -Force -ErrorAction SilentlyContinue
            Set-Content -Encoding Ascii -Path $hostsPath -Value $newHostsContent 
            $hostsWritten = $true
        }
        catch {
            Start-Sleep -Seconds 1
        }
    }
}
