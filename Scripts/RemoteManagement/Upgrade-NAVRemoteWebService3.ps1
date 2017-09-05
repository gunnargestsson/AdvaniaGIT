Function Upgrade-NAVRemoteWebService3 {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session
    )
    PROCESS 
    {
        Invoke-Command -Session $Session -ScriptBlock `
            {
                Enable-NAVWebServices3 -SetupParameters $SetupParameters
            }
    }    
}