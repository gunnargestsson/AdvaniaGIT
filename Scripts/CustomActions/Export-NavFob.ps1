if ($env:bamboo_build_working_directory) {
    $ObjectFileName = (Join-Path $env:bamboo_build_working_directory 'AllObjects.fob')
} else {
    $ObjectFileName = (Join-Path $SetupParameters.workFolder 'AllObjects.fob')
}

Write-Host -Object 'Exporting all objects...'            
Export-NAVApplicationGITObject -SetupParameters $SetupParameters -BranchSettings $BranchSettings -Path $ObjectFileName -Filter 'Compiled=0|1' 
Write-Host -Object "Export to $($ObjectFileName) completed"