Function Get-DockerWWWRootPath {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session
    )

    Invoke-Command -Session $Session -ScriptBlock { Get-WWWRootPath }    
}