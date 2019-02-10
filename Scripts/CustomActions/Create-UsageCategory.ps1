$menuItems = @()
foreach ($subfolder in ($SetupParameters.ObjectsPath,$SetupParameters.DeltasPath,$SetupParameters.NewSyntaxObjectsPath,$SetupParameters.NewSyntaxDeltasPath)) {
    if (Test-Path -Path $subfolder -PathType Container) {
        $menuSuiteFiles = Get-ChildItem -Path (Join-Path $subfolder 'MEN*.DELTA')
        foreach ($menuSuiteFile in $menuSuiteFiles) {
           $menuItems += Read-MenuSuite -ObjectFilePath $menuSuiteFile.FullName
        } 
        $menuSuiteFiles = Get-ChildItem -Path (Join-Path $subfolder 'MEN*.TXT')
        foreach ($menuSuiteFile in $menuSuiteFiles) {
           $menuItems += Read-MenuSuite -ObjectFilePath $menuSuiteFile.FullName
        } 
    }
}

    
$ALFiles = Get-ChildItem -Path (Join-Path $SetupParameters.Repository 'AL') -Filter *.al -Recurse
foreach ($ALFile in $ALFiles) {
    Write-Verbose "Handling object $ALFile.BasicName"
    $ALFileData = (Get-Content -Path $ALFile.FullName -Encoding UTF8) -split "`r`n"   
    $alObjectInfo = $ALFileData.Split(' ')
    Write-Verbose "Searching MenuSuite for $($alObjectInfo[0]) $($alObjectInfo[1])"  
    $menuSuiteItem = $menuItems | Where-Object -Property RunObjectType -ieq $alObjectInfo[0] | Where-Object -Property RunObjectId -ieq $alObjectInfo[1]
    if ($menuSuiteItem) {
        Write-Verbose "found MenuItem $($menuSuiteItem.Id)"
        $ALFileOutputData = ""
        for ($c = 0; $c -lt 2; $c++) {
            $ALFileOutputData += $ALFileData.Item($c)
            $ALFileOutputData += "`r`n"
        }
        if ([bool]($menuSuiteItem.PSObject.Properties.name -match "AccessByPermission")) {
            $ALFileOutputData += "    AccessByPermission = $($menuSuiteItem.AccessByPermission);"
            $ALFileOutputData += "`r`n"    
        }
        if ([bool]($menuSuiteItem.PSObject.Properties.name -match "ApplicationArea")) {
            $ALFileOutputData += "    ApplicationArea = $($menuSuiteItem.ApplicationArea);"
            $ALFileOutputData += "`r`n"    
        }
        if ([bool]($menuSuiteItem.PSObject.Properties.name -match "DepartmentCategory")) {
            $ALFileOutputData += "    UsageCategory = $($menuSuiteItem.DepartmentCategory);"
            $ALFileOutputData += "`r`n"    
        }
        for ($c = 2; $c -lt $ALFileData.Length; $c++) {
            $ALFileOutputData += $ALFileData.Item($c)
            $ALFileOutputData += "`r`n"
        }
        Write-Host "Updated $($ALFile.Name)"
        Set-Content -Path $ALFile.FullName -Value $ALFileOutputData -Encoding UTF8
    }
}
    
