Function New-AzureSqlDatabaseBacpac {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$AzureResourceGroup,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SqlServer,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DatabaseName
    )
    
    $databaseExists = Get-AzureRmSqlDatabase -DatabaseName $DatabaseName -ResourceGroupName $AzureResourceGroup.ResourceGroupName -ServerName $SqlServer.ServerName -ErrorAction SilentlyContinue
    if ($databaseExists) {
        $newBacpac = Read-Host -Prompt "Type name for new bacpac (default = ${DatabaseName}.bacpac)"
        if ($newBacpac -eq "") { $newBacpac = "${DatabaseName}.bacpac" }

        $BacpacPath = Join-Path (Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) "backup") $newBacpac
        if (Test-Path $BacpacPath) {
            Write-Host -ForegroundColor Red "$BacpacPath already exists!"
            $anyKey = Read-Host "Press enter to continue..."
            break
        }

        $SqlPackagePath = Get-SqlPackagePath

        $UserName = $Credential.UserName
        $Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password))

        Write-Host "Starting Database Export (will take some time)..."
        $Arguments = @("/action:Export /targetfile:""$BacpacPath"" /sourceservername:$($SqlServer.ServerName).database.windows.net /sourceuser:${UserName} /sourcepassword:${Password} /sourcedatabasename:${DatabaseName}")
        Start-Process -FilePath $SqlPackagePath -ArgumentList @Arguments -NoNewWindow -Wait -ErrorAction Stop
    }
}