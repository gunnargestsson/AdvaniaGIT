function Start-DockerCustomAction
{
    param
    (
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$BranchSettings,
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyName=$true)]
    [String]$ScriptName,
    [Parameter(Mandatory=$False, ValueFromPipelineByPropertyName=$true)]
    [String]$BuildFolder,
    [Parameter(Mandatory=$False, ValueFromPipelineByPropertyName=$true)]
    [HashTable]$BuildSettings
    )

    $Session = New-DockerSession -DockerContainerId $BranchSettings.dockerContainerId
    Invoke-Command -Session $Session -ScriptBlock {
        param([String]$Repository,[String]$ScriptName,[String]$BuildFolder,[HashTable]$BuildSettings, [String]$LocaleName)
        Set-WinSystemLocale -SystemLocale $LocaleName
        Set-Location "C:\AdvaniaGIT\Scripts"
        .\Start-CustomAction $Repository $ScriptName $false $false $BuildFolder $BuildSettings
    } -ArgumentList ("C:\GIT", $ScriptName, $BuildFolder, $BuildSettings, (Get-WinSystemLocale).Name)
    Remove-PSSession -Session $Session 
}
