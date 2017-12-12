Function Create-NAVKontoCompanyData {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Provider,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Accountant,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$TenantConfig
    )

    $Session = Get-NAVKontoRemoteSession -Provider $Provider

    $SelectedTenant = Get-NAVRemoteInstanceTenantSettings -Session $Session -SelectedTenant $TenantConfig
    if ([string]::IsNullOrEmpty($SelectedTenant.PasswordId)) {
        Write-Host -ForegroundColor Red "Password Id is not stored in tenant configuration.  Is everyting installed and configured?"
        $response = Read-Host "Press Enter to continue"
        return
    }
    Remove-PSSession -Session $Session 

    $AdminUser = Get-NAVPasswordStateNAVUser -PasswordId $SelectedTenant.PasswordId 
    if ($AdminUser.UserName -gt "" -and $AdminUser.Password -gt "") {
        $Credential = New-Object System.Management.Automation.PSCredential("$($TenantConfig.registration_no)\$($AdminUser.UserName)", (ConvertTo-SecureString $AdminUser.Password -AsPlainText -Force))
    } else {
        $Credential = Get-Credential -Message "Remote Login to Hosts" -ErrorAction Stop    
    }    

    $KontoEncryption = Get-NAVPasswordStateUser -PasswordId $Provider.ProviderDataHashKey

    $key = [Text.Encoding]::UTF8.GetBytes($KontoEncryption.Password)
    $TenantConfig.bank_password = Decrypt-Rijndael256ECB -Key $Key -CipherText $TenantConfig.bank_password
    $TenantConfig.api_key = Decrypt-Rijndael256ECB -Key $Key -CipherText $TenantConfig.api_key

    Write-Host "Executing SetTenantConfiguration..."
    $Company = [System.Uri]::EscapeDataString($TenantConfig.CompanyList[0])
    $Service = "KontoSetupService"
    $Url = $Accountant.PublicSOAPBaseUrl.Replace("?tenant=<tenant>","/${Company}/Codeunit/${Service}?tenant=$($TenantConfig.registration_no)")
    $Soap = New-WebServiceProxy -Uri $Url -Credential $Credential
    $Soap.Url = $Url
    $Soap.Timeout = 10000000
    $SetupJson = $TenantConfig | ConvertTo-Json
    $ResponseMessage = ""
    try {
        $Success = $Soap.SetTenantConfiguration($SetupJson, [ref] $ResponseMessage) 
    } catch {
        $Success = $false
        $ResponseMessage = "Unable to connect to NAV Tenant as $($Credential.UserName) via : $Url"
        $ErrorMessage = $_.Exception.Message
    }
    if ($Success) {
        Write-Host "Execution succesful!"
        $TenantConfig = Update-NAVKontoTenantConfig -Provider $Provider -Accountant $Accountant -TenantConfig $TenantConfig -Availability "Available"
    } else {        
        Write-Host -ForegroundColor Red "Execution failes: $ResponseMessage"
        Write-Host ""
        Write-Host -ForegroundColor Red $ErrorMessage
        Write-host ""
        $TenantConfig = Update-NAVKontoTenantConfig -Provider $Provider -Accountant $Accountant -TenantConfig $TenantConfig -Availability "Unavailable"
    }
    $response = Read-Host -Prompt "Press Enter to continue"
}