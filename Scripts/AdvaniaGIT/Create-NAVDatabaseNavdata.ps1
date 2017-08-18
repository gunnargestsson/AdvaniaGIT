function Create-NAVDatabaseNavdata
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$NavdataFilePath
    )
    $TempNavdataFilePath = Join-Path $SetupParameters.LogPath "NAVBackup.Navdata"
    Load-InstanceAdminTools -SetupParameters $SetupParameters

    Export-NAVData `
      -DatabaseServer (Get-DatabaseServer -BranchSettings $BranchSettings) `
      -DatabaseName $BranchSettings.databaseName `
      -FilePath $TempNavdataFilePath `
      -IncludeApplication `
      -IncludeApplicationData `
      -IncludeGlobalData `
      -AllCompanies

    UnLoad-InstanceAdminTools

    if (!$NavdataFilePath) { $NavdataFilePath = Join-Path $SetupParameters.BackupPath "$($SetupParameters.navRelease)-$($SetupParameters.projectName).Navdata" }    
    if (!(Test-Path $TempNavdataFilePath)) { Show-ErrorMessage -SetupParameters $SetupParameters -ErrorMessage "Failed to create Navdata" }
    Move-Item -Path $TempNavdataFilePath -Destination $NavdataFilePath -Force
    Write-Host "Backup $NavdataFilePath Created..."
}
    