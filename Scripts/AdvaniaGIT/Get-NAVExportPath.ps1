function Get-NAVExportPath
{
    [CmdletBinding()]
    param
    (
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [String]$Repository,
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [String]$WorkFolder,
    [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
    [String]$StoreAllObjects = ""

    )
    if ($StoreAllObjects.ToUpper() -eq "TRUE" -or $StoreAllObjects -eq $true) {
        return $Repository        
    } else {
        return $WorkFolder
    }

}
