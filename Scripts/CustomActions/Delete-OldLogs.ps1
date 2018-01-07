Get-Childitem -Path (Split-Path $SetupParameters.LogPath -Parent) |
    Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-7)} | 
    Remove-Item -Recurse

Remove-NAVDockerClientFolders 

Write-Host "Files and folder older than seven days have been deleted from $(Split-Path $SetupParameters.LogPath -Parent)..."

