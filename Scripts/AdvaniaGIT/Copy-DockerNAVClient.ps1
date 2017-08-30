Function Copy-DockerNAVClient {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings
    )
    $Session = New-DockerSession -DockerContainerId $BranchSettings.dockerContainerId
    Invoke-Command -Session $Session -ScriptBlock {
        param([String]$LogFolder)
        Write-Host "Copying RoleTailored Client to Host Computer..."
        $Source = Get-Item -Path "C:\Program Files (x86)\Microsoft Dynamics NAV\*\RoleTailored Client"
        $Destination = Join-Path "C:\Host\Log" $LogFolder
        Copy-Item -Path $Source.FullName -Destination $Destination -Recurse -Force
        $ClientUserSettingsFileName = "C:\Run\ClientUserSettings.config"
        Copy-Item -Path $ClientUserSettingsFileName -Destination $Destination -Force
    } -ArgumentList (Split-Path $SetupParameters.LogPath -Leaf)
    Remove-PSSession $Session
}
        