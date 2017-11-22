Function New-NAVAzureSqlDatabaseLicense {
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
        $selectedLicenseFilePath = (Get-LocalLicenseFilePath).FullName
        if (Test-Path $selectedLicenseFilePath) {
            $UserName = $Credential.UserName
            $Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password))

            $LicenseData = [Byte[]] (Get-Content -Path $selectedLicenseFilePath -Encoding Byte)
            Upload-NAVLicenseToSQL -Server "$($SqlServer.ServerName).database.windows.net" -Database $DatabaseName -LicenseData $LicenseData -Username $UserName -Password $Password
            Write-Host "License uploaded..."
            $anyKey = Read-Host "Press enter to continue..."
        }
    }
}