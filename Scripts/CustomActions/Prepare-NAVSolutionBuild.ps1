# Get variables
$Location = (Get-Location).Path
$GitSettings = Get-GITSettings
$sourcebranch = git.exe rev-parse --abbrev-ref HEAD 

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

# Clone the base branch
Write-Host Get objects from $SetupParameters.baseBranch
git.exe clone --single-branch --branch $($SetupParameters.baseBranch) --verbose $($SetupParameters.SourceRepository) $($SetupParameters.baseBranch) --quiet
$BranchFolder = Join-Path $TempFolder $SetupParameters.baseBranch
$BranchSetupParameters = Combine-Settings (Get-Content (Join-Path $BranchFolder (Split-Path $SetupParameters.setupPath -Leaf)) | Out-String | ConvertFrom-Json) $GitSettings
Write-Host Copying files from (Join-Path (Join-Path $BranchFolder $BranchSetupParameters.objectsPath) '*.txt') to (Join-Path $MergeFolder 'Base') 
Copy-Item -Path (Join-Path (Join-Path $BranchFolder $BranchSetupParameters.objectsPath) '*.txt') -Destination (Join-Path $MergeFolder 'Base') -Force

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
        Copy-Item -Path (Join-Path (Join-Path $BranchFolder $BranchSetupParameters.deltasPath) '*.delta') -Destination $branchMergeFolder -Force
        $DeltaFolderIndexNo += 10
    }
}

# Copy Customers Deltas
Write-Host Get deltas from Customer
$branchMergeFolder = (Join-Path (Join-Path $MergeFolder 'Deltas') ($DeltaFolderIndexNo.ToString() + $sourcebranch))
New-Item $branchMergeFolder -ItemType Directory | Out-Null
Write-Host Copying files from (Join-Path $SetupParameters.deltasPath '*.delta') to $branchMergeFolder 
Copy-Item -Path (Join-Path $SetupParameters.deltasPath '*.delta') -Destination $branchMergeFolder -Force
$DeltaFolderIndexNo += 10

# Back to Workfolder and clean GIT folder
Set-Location $Location
Remove-Item $TempFolder -Recurse -Force -ErrorAction SilentlyContinue
