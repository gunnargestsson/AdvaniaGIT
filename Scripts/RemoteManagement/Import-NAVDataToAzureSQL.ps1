Function Import-NAVDataToAzureSQL {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SqlServer,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$DatabaseName
    )

    $navVersion = Get-NAVVersionSelection
    $SetupParameters = New-Object -TypeName PSObject
    $SetupParameters | Add-Member -MemberType NoteProperty -Name navServicePath -Value (Join-Path $env:ProgramFiles "Microsoft Dynamics NAV\$($navVersion.mainVersion)\Service")
    $SetupParameters | Add-Member -MemberType NoteProperty -Name navIdePath -Value (Join-Path ${env:ProgramFiles(x86)} "Microsoft Dynamics NAV\$($navVersion.mainVersion)\Roletailored Client")
    $SetupParameters | Add-Member -MemberType NoteProperty -Name LogPath -Value $env:TEMP
    if (!(Test-Path -Path (Join-Path $SetupParameters.navServicePath 'Microsoft.Dynamics.Nav.Management.psm1'))) { exit }

    $UserName = $Credential.UserName
    $Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password))   
    $Result = Get-SQLCommandResult -Server "$($SqlServer.ServerName).database.windows.net" -Database $DatabaseName -Command "SELECT COUNT([object_id]) as [ReadyForImport] from sys.tables where name = '`$ndo`$dbproperty'" -Username $UserName -Password $Password
    if ($Result.ReadyForImport -eq 0) {    
        Write-Host -ForegroundColor Red "Database $DatabaseName has not been initiated by NAV.  Import not possible..."
        break
    } else {

        $SelectedNavdataFile = Get-LocalNavdataFilePath
        if (!$SelectedNavdataFile) { break }
        if (Test-Path $SelectedNavdataFile.FullName) {
            Load-InstanceAdminTools -SetupParameters $SetupParameters
            $WhatToLoad = Read-Host -Prompt "What to import ? (All, Tenant, Company)"
            if ($WhatToLoad -ilike "A*") {
                Import-NAVData -DatabaseServer "$($SqlServer.ServerName).database.windows.net" -DatabaseName $DatabaseName -DatabaseCredentials $Credential -FilePath $SelectedNavdataFile.FullName -IncludeApplication -IncludeApplicationData -IncludeGlobalData -AllCompanies -Force 
            } 
            if ($WhatToLoad -ilike "T*") {
                Import-NAVData -DatabaseServer "$($SqlServer.ServerName).database.windows.net" -DatabaseName $DatabaseName -DatabaseCredentials $Credential -FilePath $SelectedNavdataFile.FullName -IncludeGlobalData -AllCompanies -Force 
            } 
            if ($WhatToLoad -ilike "C*") {
                Import-NAVData -DatabaseServer "$($SqlServer.ServerName).database.windows.net" -DatabaseName $DatabaseName -DatabaseCredentials $Credential -FilePath $SelectedNavdataFile.FullName -AllCompanies -Force
            }         
        }    
    }
    $input = Read-Host -Prompt "Press Enter to continue..."
}