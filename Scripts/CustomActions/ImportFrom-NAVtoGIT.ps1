Check-GitNotUnattached
Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings 
Load-ModelTools -SetupParameters $SetupParameters
$ExportPath = (Join-Path (Get-NAVExportPath -Repository $Repository -WorkFolder $WorkFolder -StoreAllObjects $SetupParameters.storeAllObjects) $SetupParameters.objectsPath)

Write-Host -Object ''
New-Item -Type directory -Path $ExportPath -Force -ErrorAction SilentlyContinue | Out-Null
Write-Host -Object "Deleting TXT files from Objects folder..."
Remove-Item -Path (Join-Path $ExportPath "*.*") -Force 

Update-NAVTxtFromApplication -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ObjectsPath $ExportPath
Split-Solution -SetupParameters $SetupParameters -ObjectsFilePath $ExportPath
UnLoad-ModelTools