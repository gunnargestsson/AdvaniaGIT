# Inspired by
# https://www.axians-infoma.com/navblog/dynamics-365-bc-extension-build-in-tfs-vsts-using-containers/
#

if ($SetupParameters.BuildMode) {
    $BranchWorkFolder = Join-Path $SetupParameters.rootPath "Log\$($SetupParameters.BranchId)"
    New-Item -Path $BranchWorkFolder -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
    Remove-Item -Path (Join-Path $BranchWorkFolder 'out') -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -Path (Join-Path $BranchWorkFolder 'out') -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
    

    $ALProjectFolder = $SetupParameters.VSCodePath
    $AlPackageOutParent = (Join-Path $BranchWorkFolder 'out')
    $ALPackageCachePath = (Join-Path $BranchWorkFolder 'Symbols')
    $ALAssemblyProbingPath = (Join-Path $ALProjectFolder '.netpackages')
    $ALCompilerPath = (Join-Path $BranchWorkFolder 'vsix\extension\bin\alc.exe')
    $ExtensionAppJsonFile = Join-Path $ALProjectFolder 'app.json'
    $ExtensionAppJsonObject = Get-Content -Raw -Path $ExtensionAppJsonFile | ConvertFrom-Json
    $Publisher = $ExtensionAppJsonObject.Publisher
    $Name = $ExtensionAppJsonObject.Name
    if (![String]::IsNullOrEmpty($SetupParameters.buildId)) {
        $Version = $ExtensionAppJsonObject.Version.SubString(0,$ExtensionAppJsonObject.Version.LastIndexOf('.'))
        $ExtensionAppJsonObject.Version = $Version+'.' + $SetupParameters.buildId
    }
    $ExtensionName = (Clean-NAVFileName -FileName ($Publisher + '_' + $Name + '_' + $ExtensionAppJsonObject.Version + '.app')).Replace(" ","_")    
    $ExtensionAppJsonObject | ConvertTo-Json | set-content $ExtensionAppJsonFile
    Write-Host "Using Symbols Folder: " $ALPackageCachePath
    Write-Host "Using Compiler: " $ALCompilerPath
    $AlPackageOutPath = Join-Path $AlPackageOutParent $ExtensionName
    Write-Host "Using Output Folder: " $AlPackageOutPath
    Write-Host "Using Source Folder: " $ALProjectFolder
    Set-Location -Path $ALProjectFolder
    if ([int]$SetupParameters.navVersion.Split(".")[0] -ge 13) {
        New-Item -Path $ALAssemblyProbingPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
        & $ALCompilerPath /project:.\ /packagecachepath:$ALPackageCachePath /out:$AlPackageOutPath /assemblyProbingPaths:$ALAssemblyProbingPath
    } else {
        & $ALCompilerPath /project:.\ /packagecachepath:$ALPackageCachePath /out:$AlPackageOutPath 
    }
    if (-not (Test-Path $AlPackageOutPath)) {
        Write-Host "##vso[task.logissue type=error;sourcepath=$AlPackageOutPath;]No app file was generated!"
        throw        
    }    
}
