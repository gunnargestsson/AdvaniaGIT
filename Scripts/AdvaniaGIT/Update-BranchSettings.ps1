function Update-BranchSettings
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$SettingsFilePath = "Data\BranchSettings.Json"
    ) 
    $allBranchSettings = Get-Content -Path (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) $SettingsFilePath) | Out-String | ConvertFrom-Json
    $newBranchSettings = @()
    $allBranchSettings.Branches | Where-Object -Property branchId -NE $BranchSettings.branchId | foreach {$newBranchSettings += $_}
    $newBranchSettings += $BranchSettings
    $allBranchSettings.Branches = $newBranchSettings
    Set-Content -Path (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) $SettingsFilePath) -Value ($allBranchSettings | ConvertTo-Json)             
}