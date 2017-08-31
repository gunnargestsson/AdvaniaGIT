Function New-DockerSession {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DockerContainerId
    )

    $Session = New-PSSession -ContainerId $DockerContainerId -RunAsAdministrator    
    Invoke-Command -Session $Session -ScriptBlock {
        $serviceTierFolder = (Get-Item "C:\Program Files\Microsoft Dynamics NAV\*\Service").FullName
        . (Join-Path $env:SystemDrive "Run\HelperFunctions.ps1")
    }

    Return $Session
}