Function Get-NAVRemoteDefaultLanguage {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session
    )
    PROCESS 
    {
        $DefaultLanguage = Invoke-Command -Session $Session -ScriptBlock `
            {
                Return $SetupParameters.datetimeCulture
            } 
        $DefaultLanguage 
    }    
}
