Function Copy-DockerNAVClient {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings       
    )
    $DockerSettings = Get-DockerSettings
    $ClientFolderSettings = $DockerSettings.ClientFolders | Where-Object -Property dockerContainerName -EQ $BranchSettings.dockerContainerName
    if ($ClientFolderSettings -eq $null) {
        $ClientFolderSettings = New-Object -TypeName PSObject
        $ClientFolderSettings | Add-Member -MemberType NoteProperty -Name dockerContainerName -Value $BranchSettings.dockerContainerName
        $ClientFolderSettings | Add-Member -MemberType NoteProperty -Name clientFolderPath -Value ""
    }

    if ($ClientFolderSettings.clientFolderPath -gt "") {
        if (Test-Path $ClientFolderSettings.clientFolderPath -PathType Container) {
            return $ClientFolderSettings.clientFolderPath
        }
    }

    $Session = New-DockerSession -DockerContainerId $BranchSettings.dockerContainerId
    Invoke-Command -Session $Session -ScriptBlock {
        param([String]$LogFolder)
        Write-Host "Copying RoleTailored Client to Host Computer..."
        $Source = Get-Item -Path "C:\Program Files (x86)\Microsoft Dynamics NAV\*\RoleTailored Client"
        $Destination = Join-Path "C:\Host\Log" $LogFolder
        Copy-Item -Path $Source.FullName -Destination $Destination -Recurse -Force
        $ClientUserSettingsFileName = "C:\Run\ClientUserSettings.config"
        Copy-Item -Path $ClientUserSettingsFileName -Destination (Join-Path $Destination 'RoleTailored Client') -Force
    } -ArgumentList (Split-Path $SetupParameters.LogPath -Leaf)
    Remove-PSSession $Session

    $ClientFolderSettings = New-Object -TypeName PSObject
    $ClientFolderSettings | Add-Member -MemberType NoteProperty -Name dockerContainerName -Value $BranchSettings.dockerContainerName
    $ClientFolderSettings | Add-Member -MemberType NoteProperty -Name clientFolderPath -Value (Join-Path $SetupParameters.LogPath 'RoleTailored Client')
    
    $newDockerSettings = @()
    $DockerSettings.ClientFolders | Where-Object -Property dockerContainerName -NE $BranchSettings.dockerContainerName | foreach {$newDockerSettings += $_}
    $newDockerSettings += $ClientFolderSettings
    $DockerSettings.ClientFolders = $newDockerSettings
    Update-DockerSettings -DockerSettings $DockerSettings

    return (Join-Path $SetupParameters.LogPath 'RoleTailored Client')
}
        