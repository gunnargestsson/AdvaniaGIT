if ($SetupParameters.storeAllObjects -eq "false" -or $SetupParameters.storeAllObjects -eq $false) {
    Write-Host -ForegroundColor Red "This action does not support branches not storing all objects!"
    $anyKey = Read-Host "Press enter to continue..."
    break
}

Check-GitNotUnattached
Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings 
if ($BranchSettings.dockerContainerId -gt "") {
    $SetupParameters.navIdePath = Copy-DockerNAVClient -SetupParameters $SetupParameters -BranchSettings $BranchSettings
}
Load-ModelTools -SetupParameters $SetupParameters
$ExportPath = $SetupParameters.NewSyntaxObjectsPath

Write-Host -Object ''
New-Item -Type directory -Path $ExportPath -Force -ErrorAction SilentlyContinue | Out-Null
Write-Host -Object "Deleting TXT files from New Syntax Objects folder..."
Remove-Item -Path (Join-Path $ExportPath "*.*") -Force 

Update-NAVTxtFromApplication -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ObjectsPath $ExportPath -ExportWithNewSyntax
if ($SetupParameters.objectProperties -eq "false") {
    Write-Host "Clearing object properties..."
    Set-NAVApplicationObjectProperty -TargetPath $ExportPath -VersionListProperty '' -DateTimeProperty '' -ModifiedProperty No
} elseif ($SetupParameters.datetimeCulture -gt "" -and $SetupParameters.datetimeCulture -ne (Get-Culture).Name) {
    Write-Host "Converting Date and Time properties from $((Get-Culture).Name) to $($SetupParameters.datetimeCulture)..."
    Convert-NAVObjectsDateTime -FromCulture (Get-Culture).Name -ToCulture $SetupParameters.datetimeCulture -ObjectPath (Join-Path $ExportPath "*.TXT")
}

UnLoad-ModelTools
