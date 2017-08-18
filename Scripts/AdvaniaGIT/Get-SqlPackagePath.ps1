Function Get-SqlPackagePath {
    # 1. Get SQL Server Version 
    $SQLKey = Get-ItemProperty "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL"   
    $SQLVersionNum = [regex]::Match($SQLKey.MSSQLSERVER, "\d\d").Value 
 
    $ToolPath = "C:\Program Files (x86)\Microsoft SQL Server\$($SQLVersionNum)0\DAC\bin\SqlPackage.exe" 
    if (Test-Path $ToolPath) { Return $ToolPath }

    $files = @()
    $files += Get-Item -Path "$(${env:ProgramFiles(x86)})\Microsoft*" | Get-ChildItem -Filter "sqlpackage.exe" -Recurse -ErrorAction SilentlyContinue
    $files += Get-Item -Path "$($env:ProgramFiles)\Microsoft*" | Get-ChildItem -Filter "sqlpackage.exe" -Recurse -ErrorAction SilentlyContinue

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