Function Get-SqlPackagePath {
    $files = Get-Item -Path ${env:ProgramFiles(x86)} -Filter "Microsoft*" | Get-ChildItem -Filter "sqlpackage.exe" -Recurse -ErrorAction SilentlyContinue
    $files += Get-Item -Path $env:ProgramFiles -Filter "Microsoft*" | Get-ChildItem -Filter "sqlpackage.exe" -Recurse -ErrorAction SilentlyContinue

    if ($Files) {
        foreach ($file in $files) {
            if ($selectedFile) {
                if ($file.VersionInfo.FileMajorPart -ge $selectedFile.VersionInfo.FileMajorPart -and `
                    $file.VersionInfo.FileMinorPart -ge $selectedFile.VersionInfo.FileMinorPart -and `
                    $file.VersionInfo.FileBuildPart -ge $selectedFile.VersionInfo.FileBuildPart) 
                {
                    $selectedFile = $file
                }
            
            } else {
                $selectedFile = $file
            }
        }
    }
    return $selectedFile.FullName
}