function Start-DockerCustomAction
{
    param
    (
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyName=$true)]
    [String]$ScriptName
    )

    $Session = New-DockerSession -DockerContainerId $DockerContainerId
    Invoke-Command -Session $Session -ScriptBlock {
        param([String]$Repository,[String]$ScriptName,[String]$BuildFolder,[HashTable]$BuildSettings)
        Set-Location "C:\AdvaniaGIT\Scripts"
        .\Start-CustomAction $Repository $ScriptName $false $false $BuildFolder $BuildSettings
    } -ArgumentList ($Repository, $ScriptName, $BuildFolder, $BuildSettings)
    Remove-PSSession -Session $Session 
}
