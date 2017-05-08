$ObjectFileName = (Join-Path $workFolder 'AllObjects.fob')

Write-Host -Object 'Exporting all objects...'            
Export-NAVApplicationGITObject -SetupParameters $SetupParameters -BranchSettings $BranchSettings -Path $ObjectFileName -Filter 'Compiled=0|1' 
Write-Host -Object "Export to $($ObjectFileName) completed"