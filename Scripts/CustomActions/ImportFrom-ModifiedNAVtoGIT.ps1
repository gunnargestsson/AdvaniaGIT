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
$ExportPath = Join-Path $SetupParameters.WorkFolder 'Target.txt'
Remove-Item -Path $ExportPath -Force -ErrorAction SilentlyContinue

Export-ModifiedNAVTxtFromApplication -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ObjectsPath $ExportPath
Set-NAVApplicationObjectProperty -TargetPath $ExportPath -ModifiedProperty No
if ($SetupParameters.datetimeCulture -gt "" -and $SetupParameters.datetimeCulture -ne (Get-Culture).Name) {
    Write-Host "Converting Date and Time properties from $((Get-Culture).Name) to $($SetupParameters.datetimeCulture)..."
    $TempObjectPath = Join-Path $SetupParameters.LogPath Convert
    New-Item -Path $TempObjectPath -ItemType Directory | Out-Null
    Split-NAVApplicationObjectFile -Source $ExportPath -Destination $TempObjectPath -Force
    Convert-NAVObjectsDateTime -FromCulture (Get-Culture).Name -ToCulture $SetupParameters.datetimeCulture -ObjectPath (Join-Path $TempObjectPath "*.TXT")
    Copy-Item -Path (Join-Path $TempObjectPath "*.TXT") -Destination $SetupParameters.ObjectsPath -Force 
    Remove-Item $TempObjectPath -Recurse -Force 
} else {
    Split-NAVApplicationObjectFile -Source $ExportPath -Destination $SetupParameters.ObjectsPath -Force
}
UnLoad-ModelTools
