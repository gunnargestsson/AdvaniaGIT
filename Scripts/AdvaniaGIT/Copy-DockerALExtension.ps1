Function Copy-DockerALExtension {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings
    )
    $Session = New-DockerSession -DockerContainerId $BranchSettings.dockerContainerId
    Invoke-Command -Session $Session -ScriptBlock {
        param([String]$LogFolder)
        Write-Host "Copying AL Extension to Host Computer..."
        $wwwRootPath = (Get-Item "HKLM:\SOFTWARE\Microsoft\InetStp").GetValue("PathWWWRoot")
        $wwwRootPath = [System.Environment]::ExpandEnvironmentVariables($wwwRootPath)
        $Source = Join-Path $wwwRootPath "http\*.vsix"
        $Destination = Join-Path "C:\Host\Log" $LogFolder
        Copy-Item -Path $Source -Destination $Destination -Recurse -Force
    } -ArgumentList (Split-Path $SetupParameters.LogPath -Leaf)
    Remove-PSSession $Session
}
        