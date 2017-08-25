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
        $Source = Join-Path (Get-WWWRootPath) "http\nav\Win\Deployment\ApplicationFiles"
        $Destination = Join-Path "C:\Host\Log" $LogFolder
        Copy-Item -Path $Source -Destination $Destination -Recurse -Force
        $navDvdPath = "C:\NAVDVD"
        $ClientUserSettingsFileName = Join-Path (Get-ChildItem -Path "$NavDvdPath\RoleTailoredClient\CommonAppData\Microsoft\Microsoft Dynamics NAV" -Directory | Select-Object -Last 1).FullName "ClientUserSettings.config"
        Copy-Item -Path $ClientUserSettingsFileName -Destination $Destination -Force
    } -ArgumentList (Split-Path $SetupParameters.LogPath -Leaf)
    Remove-PSSession $Session
}
        