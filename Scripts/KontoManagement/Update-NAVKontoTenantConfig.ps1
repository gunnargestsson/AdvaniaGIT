Function Update-NAVKontoTenantConfig {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Provider,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Accountant,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$TenantConfig,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [string]$Availability
    )

    $KontoConfig = Get-NAVKontoConfig   

    $newProviders = @()
    $KontoConfig.Providers | Where-Object -Property ProviderId -NE $Provider.ProviderId | foreach {$newProviders += $_}
    
    $newAccountants = @()
    $Provider.Accountants | Where-Object -Property guid -NE $Accountant.guid | foreach {$newAccountants += $_}
    
    $newTenants = @()
    $Accountant.Tenants | Where-Object -Property guid -NE $TenantConfig.guid | foreach {$newTenants += $_}

    $Response = Get-NAVKontoResponse -Provider $Provider -Query "get-tenant?guid=$($TenantConfig.guid)"
    if ($Response.status -eq $false) {
        Write-Host -ForegroundColor Red $Response.message
        Read-Host -Prompt "Press enter to continue"
        Return $TenantConfig
    }

    $TenantSettings = $Response.result
    if (![bool]($TenantSettings.PSObject.Properties.name -match "Availability")) {
            $TenantSettings | Add-Member -MemberType NoteProperty -Name Availability -Value "Unavailable" -Force
        }
    $TenantSettings.Availability = $Availability

    $newTenants += $TenantSettings
    $Accountant.Tenants = $newTenants
    $newAccountants += $Accountant
    $Provider.Accountants = $newAccountants
    $newProviders += $Provider

    $KontoConfig.Providers = $newProviders
    Update-NAVKontoConfig -KontoConfig $KontoConfig
    Return $TenantConfig
}