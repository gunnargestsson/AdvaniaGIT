$VMAdmin = Get-NAVPasswordStateUser -PasswordId $DeploymentSettings.NavServerPid
$VMCredential = New-Object System.Management.Automation.PSCredential($VMAdmin.UserName, (ConvertTo-SecureString $VMAdmin.Password -AsPlainText -Force))

Write-Host "Connecting to $($DeploymentSettings.instanceServer)..."
$Session = New-NAVRemoteSession -Credential $VMCredential -HostName $DeploymentSettings.instanceServer

Write-Host "Combining Navdata to one file..."
Invoke-Command -Session $Session -ScriptBlock {
    param([string]$instanceName)    
    $navDataFilePath = Join-Path $SetupParameters.BackupPath "$($SetupParameters.navRelease)-${instanceName}.navdata"
    Write-Host Combining parts to file ${navDataFilePath}...
    Remove-Item -Path $navDataFilePath -ErrorAction SilentlyContinue

    $files = Get-ChildItem -Path "${navDataFilePath}.part.*"
    $writeStream = [System.IO.File]::Create($navDataFilePath)
    foreach ($file in $files) {
        write-host Reading $file.Name    
        $part = [System.IO.File]::OpenRead($file.FullName)
        $part.CopyTo($writeStream);
        $part.Dispose()
        Remove-Item -Path $file.FullName
    }
    $writeStream.Flush()
    $writeStream.Close()

    if (Test-Path -Path $navDataFilePath) {        
        Write-Host "navdata file copied to test machine"
    } else {
        Write-Host "Unable to create navdata file!"
        throw
    }
} -ArgumentList ($DeploymentSettings.instanceName)


$Session | Remove-PSSession
