if ($SetupParameters.storeAllObjects -eq "false" -or $SetupParameters.storeAllObjects -eq $false) {
    Write-Host -ForegroundColor Red "This action does not support branches not storing all objects!"
    $anyKey = Read-Host "Press enter to continue..."
    break
}

Check-GitNotUnattached
Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings 
Load-ModelTools -SetupParameters $SetupParameters
$ExportPath = Join-Path $SetupParameters.WorkFolder 'Target.txt'
Remove-Item -Path $ExportPath -Force -ErrorAction SilentlyContinue

Export-ModifiedNAVTxtFromApplication -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ObjectsPath $ExportPath
Set-NAVApplicationObjectProperty -TargetPath $ExportPath -ModifiedProperty No
Split-NAVApplicationObjectFile -Source $ExportPath -Destination $SetupParameters.ObjectsPath -Force
UnLoad-ModelTools