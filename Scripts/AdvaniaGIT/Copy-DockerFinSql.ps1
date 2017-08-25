Function Copy-DockerFinSql {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings
    )
    $Session = New-DockerSession -DockerContainerId $BranchSettings.dockerContainerId
    Invoke-Command -Session $Session -ScriptBlock {
        param([String]$LogFolder)
        $Source = Join-Path (Get-WWWRootPath) "http\nav\Finsql\Deployment\ApplicationFiles"
        $Destination = Join-Path "C:\Host\Log" $LogFolder
        Copy-Item -Path $Source -Destination $Destination -Recurse -Force
    } -ArgumentList (Split-Path $SetupParameters.LogPath -Leaf)
    Remove-PSSession $Session
}
        