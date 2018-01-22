Function New-NAVAppJson
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters
    )
    $AppJsonPath = Join-Path $SetupParameters.VSCodePath "app.json"
    
    if (!(Test-Path $SetupParameters.VSCodePath)) {
        New-Item -Path $SetupParameters.VSCodePath -ItemType Directory | Out-Null
    }

    if (Test-Path $AppJsonPath) {
        return
    }

    $AppSettings = New-Object -TypeName PSObject   
    # Add Text Type Objects
    $AppSettings | Add-Member -MemberType NoteProperty -Name id -Value $SetupParameters.branchId
    $AppSettings | Add-Member -MemberType NoteProperty -Name name -Value $SetupParameters.projectName
    $AppSettings | Add-Member -MemberType NoteProperty -Name publisher -Value $SetupParameters.appPublisher
    $AppSettings | Add-Member -MemberType NoteProperty -Name brief -Value $SetupParameters.appBriefDescription
    $AppSettings | Add-Member -MemberType NoteProperty -Name description -Value $SetupParameters.appManifestDescription
    $AppSettings | Add-Member -MemberType NoteProperty -Name version -Value "$($SetupParameters.navVersion.Split(".")[0]).0.0.0"
    $AppSettings | Add-Member -MemberType NoteProperty -Name privacyStatement -Value $SetupParameters.appPrivacyStatement
    $AppSettings | Add-Member -MemberType NoteProperty -Name EULA -Value $SetupParameters.appEula
    $AppSettings | Add-Member -MemberType NoteProperty -Name help -Value $SetupParameters.appHelp
    $AppSettings | Add-Member -MemberType NoteProperty -Name url -Value $SetupParameters.appUrl
    $AppSettings | Add-Member -MemberType NoteProperty -Name logo -Value $SetupParameters.appIcon
    $AppSettings | Add-Member -MemberType NoteProperty -Name platform -Value "$($SetupParameters.navVersion.Split(".")[0]).0.0.0"
    $AppSettings | Add-Member -MemberType NoteProperty -Name application -Value "$($SetupParameters.navVersion.Split(".")[0]).0.0.0"
        
    foreach ($Property in @(Get-Member -InputObject $AppSettings -MemberType NoteProperty).Name) {
        if ($AppSettings."$Property" -eq $null) { $AppSettings."$Property" = "" }
    }

    if ($AppSettings.version -eq "") { $AppSettings.version = "1.0.0.0" }

    # Add Array Type Objects
    $AppSettings | Add-Member -MemberType NoteProperty -Name capabilities -Value $SetupParameters.appCapabilities
    $AppSettings | Add-Member -MemberType NoteProperty -Name screenshots -Value $SetupParameters.appScreenShots
    foreach ($Property in @(Get-Member -InputObject $AppSettings -MemberType NoteProperty).Name) {
        if ($AppSettings."$Property" -eq $null) { $AppSettings."$Property" = @() }
    }

    Set-Content -Path $AppJsonPath -Value ($AppSettings | ConvertTo-Json)
}

    