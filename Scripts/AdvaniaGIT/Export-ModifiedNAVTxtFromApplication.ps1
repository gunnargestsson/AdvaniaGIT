<#
    .Synopsis
    Update .txt files on disk from objects in NAV database
    .DESCRIPTION
    Scripts tries to update .txt files (folder with .txt files) to have up-to-date version of objects from NAV Database
    .EXAMPLE
    Update-TxtFromNAVApplication.ps1 -Path E:\git\NAV\Objects\ -Server MySQLServer -Database MyNAVDatabase
#>
function Export-ModifiedNAVTxtFromApplication
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [string]$ObjectsPath
    )
    Write-Host -Object 'Exporting modified files...'
    Export-NAVApplicationGITObject -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ExportTxtSkipUnlicensed -Path $ObjectsPath -Filter 'Modified=1' 
}
