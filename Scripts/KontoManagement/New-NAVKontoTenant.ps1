Function New-NAVKontoTenant {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Provider,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Accountant
    )

    $KontoConfig = Get-NAVKontoConfig
    $guid = Read-Host -Prompt "Enter guid for new tenant"
    if ($guid -eq "") {
        return $Accountant
    }
    
    $Response = Get-NAVKontoResponse -Provider $Provider -Query "get-tenant?guid=$guid"
    if ($Response.status -eq $false) {
        Write-Host -ForegroundColor Red $Response.message
        Read-Host -Prompt "Press enter to continue"
        Return $Accountant                
    }
    $newProviders = @()
    $KontoConfig.Providers | Where-Object -Property ProviderId -NE $Provider.ProviderId | foreach {$newProviders += $_}
    
    $newAccountants = @()
    $Provider.Accountants | Where-Object -Property guid -NE $Accountant.guid | foreach {$newAccountants += $_}
    
    $Accountant.Tenants += $Response.result
    $newAccountants += $Accountant

    $Provider.Accountants = $newAccountants
    $newProviders += $Provider

    $KontoConfig.Providers = $newProviders
    Update-NAVKontoConfig -KontoConfig $KontoConfig
    return $Accountant
}