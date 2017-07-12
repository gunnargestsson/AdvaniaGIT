Function Get-NAVRemoteInstanceDefaultTenant {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstance
    )
    PROCESS 
    {    
        if ($SelectedInstance.TenantList.Count -ge 1) {
            $tenant = $SelectedInstance.TenantList | Select-Object -First 1
        } else {
            $tenant = New-Object -TypeName PSObject
            $tenant | Add-Member -MemberType NoteProperty -Name CustomerRegistrationNo -Value ""
            $tenant | Add-Member -MemberType NoteProperty -Name Id -Value "default"
            $tenant | Add-Member -MemberType NoteProperty -Name PasswordPid -Value ""
            $tenant | Add-Member -MemberType NoteProperty -Name ServerInstance -Value $SelectedInstance.ServerInstance
            $tenant | Add-Member -MemberType NoteProperty -Name LicenseNo -Value ""
            $tenant | Add-Member -MemberType NoteProperty -Name ClickOnceHost -Value "" 
            $tenant | Add-Member -MemberType NoteProperty -Name CustomerName -Value ""
            $tenant | Add-Member -MemberType NoteProperty -Name CustomerEMail -Value ""
            $tenant | Add-Member -MemberType NoteProperty -Name Language -Value (Get-Culture).Name
            $tenant | Add-Member -MemberType NoteProperty -Name AadTenantId -Value ""
            $tenant | Add-Member -MemberType NoteProperty -Name AllowAppDatabaseWrite -Value "True"
            $tenant | Add-Member -MemberType NoteProperty -Name AlternateId -Value "@{}"
            $tenant | Add-Member -MemberType NoteProperty -Name AzureKeyVaultSettings -Value ""
            $tenant | Add-Member -MemberType NoteProperty -Name DatabaseName -Value $SelectedInstance.DatabaseName
            $tenant | Add-Member -MemberType NoteProperty -Name DatabaseServer -Value $SelectedInstance.DatabaseServer
            $tenant | Add-Member -MemberType NoteProperty -Name DatabaseUserName -Value $SelectedInstance.DatabaseUserName
            $tenant | Add-Member -MemberType NoteProperty -Name DefaultCompany -Value ""
            $tenant | Add-Member -MemberType NoteProperty -Name DefaultTimeZone -Value "UTC"
            $tenant | Add-Member -MemberType NoteProperty -Name DetailedState -Value ""
            $tenant | Add-Member -MemberType NoteProperty -Name EncryptionProvider -Value "LocalKeyFile"
            $tenant | Add-Member -MemberType NoteProperty -Name ExchangeAuthenticationMetadataLocation -Value "https://outlook.office365.com/"
            $tenant | Add-Member -MemberType NoteProperty -Name NasServicesEnabled -Value "False"
            $tenant | Add-Member -MemberType NoteProperty -Name ProtectedDatabasePassword -Value ""
            $tenant | Add-Member -MemberType NoteProperty -Name RunNasWithAdminRights -Value "False"
            $tenant | Add-Member -MemberType NoteProperty -Name State -Value "Operational"
            $tenant | Add-Member -MemberType NoteProperty -Name WSFederationLoginEndpoint -Value ""
            $tenant | Add-Member -MemberType NoteProperty -Name WSFederationMetadataLocation -Value "" 
        }
        return $tenant
    }
}