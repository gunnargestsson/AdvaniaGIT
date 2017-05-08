function Invoke-PostImportCompilation
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Object
    )
    if (($Object.Type -eq 1) -and ($Object.ID -gt 2000000004))
    {
        if ($Object.ID -eq 2000000006) 
        {
            Compile-NAVApplicationGITObject -SetupParameters $SetupParameters -BranchSettings $BranchSettings -Filter "Type=$($Object.Type);Id=$($Object.ID)" -SynchronizeSchemaChanges No
        }
        else 
        {
            Compile-NAVApplicationGITObject -SetupParameters $SetupParameters -BranchSettings $BranchSettings -Filter "Type=$($Object.Type);Id=$($Object.ID)" -SynchronizeSchemaChanges Force
        }
    }
    if ($Object.Type -eq 7) { #menusuite
        Compile-NAVApplicationGITObject -SetupParameters $SetupParameters -BranchSettings $BranchSettings -Filter "Type=$($Object.Type);Id=$($Object.ID)" -SynchronizeSchemaChanges Force
    }
}