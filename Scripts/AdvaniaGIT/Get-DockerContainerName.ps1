Function Get-DockerContainerName {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session
    )

    $ContainerName = Invoke-Command -Session $Session -ScriptBlock { return $env:COMPUTERNAME }
    Return $ContainerName.ToString()
}