$VMAdmin = Get-NAVPasswordStateUser -PasswordId $DeploymentSettings.NavServerPid
$VMCredential = New-Object System.Management.Automation.PSCredential($VMAdmin.UserName, (ConvertTo-SecureString $VMAdmin.Password -AsPlainText -Force))

Write-Host "Connecting to $($DeploymentSettings.instanceServer)..."
$Session = New-NAVRemoteSession -Credential $VMCredential -HostName $DeploymentSettings.instanceServer

Write-Host "Exporting Live Database to Navdata..."
Invoke-Command -Session $Session -ScriptBlock {
    param([string]$instanceName,[string]$tenantId='default', [string]$workFolder,[string]$backupFtpPath)
    function Split-File($inFile,  $outPrefix, [Int32] $bufSize){
        $stream = [System.IO.File]::OpenRead($inFile)
        $chunkNum = 1
        $barr = New-Object byte[] $bufSize

        while( $bytesRead = $stream.Read($barr,0,$bufsize)){
        $outFile = "$outPrefix$chunkNum"
        $ostream = [System.IO.File]::OpenWrite($outFile)
        $ostream.Write($barr,0,$bytesRead);
        $ostream.close();
        $chunkNum += 1
        }
    }

    Load-InstanceAdminTools -SetupParameters $SetupParameters
    New-Item -Path $workFolder -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    $navDataFilePath = Join-Path $workFolder "$($SetupParameters.navRelease)-${instanceName}.navdata"
    Remove-Item -Path $navDataFilePath -ErrorAction SilentlyContinue
    Write-Host Writing Customer Database to ${navDataFilePath}...
    Export-NAVData -ServerInstance $instanceName -Tenant $tenantId -IncludeApplication -IncludeApplicationData -IncludeGlobalData -AllCompanies -FilePath $navDataFilePath -Force
    if (Test-Path -Path $navDataFilePath) {        
        Split-File -inFile $navDataFilePath -outPrefix "${navDataFilePath}.part." -bufSize 1000000000
        $files = Get-ChildItem -Path "${navDataFilePath}.part.*"
        foreach ($file in $files) {
            Put-FtpFile -Server $backupFtpPath -User anonymous -Pass 'gg@advania.is' -FtpFilePath $file.Name -LocalFilePath $file.FullName
            Remove-Item $file.FullName
        }        
        Remove-Item -Path $navDataFilePath -Force
        Write-Host "navdata file copied to test machine"
    } else {
        Write-Host "Unable to create navdata file!"
        throw
    }
} -ArgumentList ($DeploymentSettings.instanceName, $DeploymentSettings.tenantId, $DeploymentSettings.tempPath, $DeploymentSettings.backupFtpPath)


$Session | Remove-PSSession
