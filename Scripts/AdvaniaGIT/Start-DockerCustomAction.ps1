function Start-DockerCustomAction
{
    param
    (
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$BranchSettings,
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyName=$true)]
    [String]$ScriptName,
    [Parameter(Mandatory=$False, ValueFromPipelineByPropertyName=$true)]
    [HashTable]$BuildSettings
    )

    $Session = New-DockerSession -DockerContainerId $BranchSettings.dockerContainerId
    Invoke-Command -Session $Session -ScriptBlock {
        param([String]$Repository,[String]$ScriptName,[HashTable]$BuildSettings)
        Set-Location "C:\AdvaniaGIT\Scripts"
        .\Start-CustomAction $Repository $ScriptName $false $false $BuildSettings
    } -ArgumentList ("C:\GIT", $ScriptName, $BuildSettings)
    Remove-PSSession -Session $Session 
}
