Function Copy-DockerALExtension {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings
    )
    Invoke-ScriptInNavContainer -containerName $BranchSettings.dockerContainerName -ScriptBlock {
        param([String]$LogFolder)
        $Extension = Get-Item -Path 'C:\Run\*.vsix'
        if (!$Extension) {
            $wwwRootPath = (Get-Item "HKLM:\SOFTWARE\Microsoft\InetStp").GetValue("PathWWWRoot")
            $wwwRootPath = [System.Environment]::ExpandEnvironmentVariables($wwwRootPath)
            $Source = Join-Path $wwwRootPath "http\*.vsix"
            $Extension = Get-Item -Path $Source
        }
        if ($Extension) {
            if (Test-Path -Path $Extension) {
                Write-Host "Copying AL Extension to Host Computer..."
                $Destination = Join-Path "C:\Host\Log" $LogFolder
                Copy-Item -Path $Extension.FullName -Destination $Destination -Recurse -Force
            }
        } 

    } -ArgumentList (Split-Path $SetupParameters.LogPath -Leaf)
}
        