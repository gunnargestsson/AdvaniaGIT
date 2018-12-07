# Get variables
$Location = (Get-Location).Path
$GitSettings = Get-GITSettings
$SolutionBranchSetup = Get-Content (Join-Path $Location (Split-Path $SetupParameters.setupPath -Leaf)) -Encoding UTF8 | Out-String | ConvertFrom-Json
$sourcebranch = git.exe rev-parse --abbrev-ref HEAD 
if ($SetupParameters.BuildMode) {
    $SetupParameters.workFolder = Join-Path $SetupParameters.rootPath "Log\$($SetupParameters.BranchId)"
    New-Item $SetupParameters.workFolder -ItemType Directory -ErrorAction SilentlyContinue| Out-Null
}

# Create GitFolder and enter it
$TempFolder = (Join-Path $SetupParameters.workFolder 'Temp')
Remove-Item $TempFolder -Recurse -Force -ErrorAction SilentlyContinue
New-Item $TempFolder -ItemType Directory -Force -ErrorAction Stop | Out-Null
Set-Location $TempFolder

# Create the Merge Folder
$MergeFolder = (Join-Path $SetupParameters.workFolder 'Merge')
Remove-Item -Path $MergeFolder -Recurse -Force -ErrorAction SilentlyContinue
New-Item $MergeFolder -ItemType Directory | Out-Null
New-Item (Join-Path $MergeFolder 'Base') -ItemType Directory | Out-Null
New-Item (Join-Path $MergeFolder 'Deltas') -ItemType Directory | Out-Null
New-Item (Join-Path $MergeFolder 'Languages') -ItemType Directory | Out-Null
New-Item (Join-Path $MergeFolder 'Tests') -ItemType Directory | Out-Null

# Clone the base branch
Write-Host Get objects from $SetupParameters.baseBranch
git.exe clone --single-branch --branch $($SetupParameters.baseBranch) --verbose $($SetupParameters.SourceRepository) $($SetupParameters.baseBranch) --quiet
$BranchFolder = Join-Path $TempFolder $SetupParameters.baseBranch
$BranchSetup = Get-Content (Join-Path $BranchFolder (Split-Path $SetupParameters.setupPath -Leaf)) -Encoding UTF8 | Out-String | ConvertFrom-Json
$BranchSetupParameters = Combine-Settings $BranchSetup $GitSettings
Write-Host Copying files from (Join-Path (Join-Path $BranchFolder $BranchSetupParameters.objectsPath) '*.txt') to (Join-Path $MergeFolder 'Base') 
Copy-Item -Path (Join-Path (Join-Path $BranchFolder $BranchSetupParameters.objectsPath) '*.txt') -Destination (Join-Path $MergeFolder 'Base') -Force
Copy-Item -Path (Join-Path (Join-Path $BranchFolder $BranchSetupParameters.languagePath) '*.txt') -Destination (Join-Path $MergeFolder 'Languages') -Force -ErrorAction SilentlyContinue
Copy-Item -Path (Join-Path (Join-Path $BranchFolder $BranchSetupParameters.testObjectsPath) '*.txt') -Destination (Join-Path $MergeFolder 'Tests') -Force -ErrorAction SilentlyContinue
Write-Host Update version information in build branch
$SolutionBranchSetup | Add-Member -MemberType NoteProperty -Name navVersion -Value $BranchSetup.navVersion -Force
$SolutionBranchSetup | Add-Member -MemberType NoteProperty -Name navBuild -Value $BranchSetup.navBuild -Force
Set-Content -Path (Join-Path $Location (Split-Path $SetupParameters.setupPath -Leaf)) -Encoding UTF8 -Value (ConvertTo-Json -InputObject $SolutionBranchSetup)

# Clone the delta branches
$DeltaFolderIndexNo = 10000
if ($SetupParameters.deltaBranchList) {
    $deltaBranchList = ($SetupParameters.deltaBranchList).split(",")
    foreach ($deltaBranch in $deltaBranchList)
    {        
        Write-Host Get deltas from $deltaBranch
        git.exe clone --single-branch --branch $deltaBranch --verbose $($SetupParameters.SourceRepository) $deltaBranch --quiet
        $BranchFolder = Join-Path $TempFolder $deltaBranch
        $BranchSetupParameters = Combine-Settings (Get-Content (Join-Path $BranchFolder (Split-Path $SetupParameters.setupPath -Leaf)) | Out-String | ConvertFrom-Json) $GitSettings
        $branchMergeFolder = (Join-Path (Join-Path $MergeFolder 'Deltas') ($DeltaFolderIndexNo.ToString() + $deltaBranch))
        New-Item $branchMergeFolder -ItemType Directory | Out-Null
        Write-Host Copying files from (Join-Path (Join-Path $BranchFolder $BranchSetupParameters.deltasPath) '*.delta') to $branchMergeFolder 
        Copy-Item -Path (Join-Path (Join-Path $BranchFolder $BranchSetupParameters.deltasPath) '*.delta') -Destination $branchMergeFolder -Force -ErrorAction SilentlyContinue
        Copy-NewItem -SourceFolder (Join-Path $BranchFolder $BranchSetupParameters.languagePath) -DestinationFolder (Join-Path $MergeFolder 'Languages') -ErrorAction SilentlyContinue
        Copy-NewItem -SourceFolder (Join-Path $BranchFolder $BranchSetupParameters.testObjectsPath) -DestinationFolder (Join-Path $MergeFolder 'Tests') -ErrorAction SilentlyContinue
        $DeltaFolderIndexNo += 10
    }
}

# Copy Customers Deltas
if (Test-Path -Path (Join-Path $SetupParameters.deltasPath '*.delta')) {
    Write-Host Get deltas from Customer
    $branchMergeFolder = (Join-Path (Join-Path $MergeFolder 'Deltas') ($DeltaFolderIndexNo.ToString() + $sourcebranch))
    New-Item $branchMergeFolder -ItemType Directory | Out-Null
    Write-Host Copying files from (Join-Path $SetupParameters.deltasPath '*.delta') to $branchMergeFolder 
    Copy-Item -Path (Join-Path $SetupParameters.deltasPath '*.delta') -Destination $branchMergeFolder -Force 
    Copy-NewItem -SourceFolder $SetupParameters.languagePath -DestinationFolder (Join-Path $MergeFolder 'Languages') -ErrorAction SilentlyContinue
    Copy-NewItem -SourceFolder $SetupParameters.testObjectsPath -DestinationFolder (Join-Path $MergeFolder 'Tests') -ErrorAction SilentlyContinue
    $DeltaFolderIndexNo += 10
}

Remove-Item -Path (Join-Path $SetupParameters.testObjectsPath "*.*") -Force -ErrorAction SilentlyContinue
New-Item -Path $SetupParameters.testObjectsPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
Remove-Item -Path (Join-Path $SetupParameters.languagePath "*.*") -Force -ErrorAction SilentlyContinue
New-Item -Path $SetupParameters.languagePath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

Copy-Item -Path (Join-Path (Join-Path $MergeFolder 'Languages') '*.txt') -Destination $SetupParameters.languagePath -Force -ErrorAction SilentlyContinue
Copy-Item -Path (Join-Path (Join-Path $MergeFolder 'Tests') '*.txt') -Destination $SetupParameters.testObjectsPath -Force -ErrorAction SilentlyContinue

# Back to Workfolder and clean GIT folder
Set-Location $Location
Remove-Item $TempFolder -Recurse -Force -ErrorAction SilentlyContinue
