<#
    .Synopsis
    Update .txt files on disk from objects in NAV database
    .DESCRIPTION
    Scripts tries to update .txt files (folder with .txt files) to have up-to-date version of objects from NAV Database
    .EXAMPLE
    Update-TxtFromNAVApplication.ps1 -Path E:\git\NAV\Objects\ -Server MySQLServer -Database MyNAVDatabase
#>
function Update-NAVTxtFromApplication
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [string]$ObjectsPath,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [Switch] $ExportWithNewSyntax
    )
    Write-Host -Object 'Exporting all files...'
    if ($ExportWithNewSyntax) {
        Export-NAVApplicationGITObject -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ExportTxtSkipUnlicensed -Path (Join-Path -Path $SetupParameters.LogPath 'all.txt') -Filter 'Compiled=0|1' -ExportWithNewSyntax
    } else {
        Export-NAVApplicationGITObject -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ExportTxtSkipUnlicensed -Path (Join-Path -Path $SetupParameters.LogPath 'all.txt') -Filter 'Compiled=0|1' 
    }

    if ([int]$SetupParameters.navVersion.Split(".")[0] -ge 12) {
        Write-Host "Removing Line Start property from objects..."
        $objectData = Get-Content -Path (Join-Path -Path $SetupParameters.LogPath 'all.txt') -Encoding oem | Select-String -Pattern "\s\[LineStart\(\d{1,10}\)\]" -notmatch
        Set-Content -Path (Join-Path -Path $SetupParameters.LogPath 'all.txt') -Encoding oem -Value $objectData
    }
    Split-NAVApplicationObjectFile -Source (Join-Path -Path $SetupParameters.LogPath 'all.txt') -Destination $ObjectsPath -Force
    Remove-Item (Join-Path -Path $SetupParameters.LogPath 'all.txt')
    Write-Host -Object ''
    Write-Host -Object 'Exported all files...'

}
