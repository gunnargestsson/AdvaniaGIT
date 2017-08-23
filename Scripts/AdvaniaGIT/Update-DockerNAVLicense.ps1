function Update-DockerNAVLicense {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$LicenseFilePath
    ) 

    Write-Host "Uploading NAV license to $($BranchSettings.dockerContainerName)/$($BranchSettings.instanceName) ..."
    $Session = New-DockerSession -DockerContainerId $BranchSettings.dockerContainerId
    $Destination = Join-Path (Join-Path (Get-DockerWWWRootPath -Session $Session) "http") (Split-Path -Path $LicenseFilePath -Leaf)
    Copy-FileToRemoteMachine -SourceFile $LicenseFilePath -DestinationFile $Destination -Session $Session
    Invoke-Command -Session $Session -ScriptBlock { 
        param([string]$LicenseFilePath)
        Import-NAVServerLicense -ServerInstance NAV -LicenseFile $LicenseFilePath -Database NavDatabase -Force 
    } -ArgumentList $Destination
    Remove-PSSession -Session $Session
}