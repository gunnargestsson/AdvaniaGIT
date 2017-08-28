Function New-NAVAppJson
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters
    )
    $AppJsonPath = Join-Path $SetupParameters.VSCodePath "app.json"

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
    $AppSettings | Add-Member -MemberType NoteProperty -Name version -Value $SetupParameters.appVersion
    $AppSettings | Add-Member -MemberType NoteProperty -Name privacyStatement -Value $SetupParameters.appPrivacyStatement
    $AppSettings | Add-Member -MemberType NoteProperty -Name EULA -Value $SetupParameters.appEula
    $AppSettings | Add-Member -MemberType NoteProperty -Name help -Value $SetupParameters.appHelp
    $AppSettings | Add-Member -MemberType NoteProperty -Name url -Value $SetupParameters.appUrl
    $AppSettings | Add-Member -MemberType NoteProperty -Name logo -Value $SetupParameters.appIcon
    $AppSettings | Add-Member -MemberType NoteProperty -Name platform -Value $SetupParameters.navVersion
        
    foreach ($Property in @(Get-Member -InputObject $AppSettings -MemberType NoteProperty).Name) {
        if ($AppSettings."$Property" -eq $null) { $AppSettings."$Property" = "" }
    }

    # Add Array Type Objects
    $AppSettings | Add-Member -MemberType NoteProperty -Name capabilities -Value $SetupParameters.appCapabilities
    $AppSettings | Add-Member -MemberType NoteProperty -Name screenshots -Value $SetupParameters.appScreenShots
    foreach ($Property in @(Get-Member -InputObject $AppSettings -MemberType NoteProperty).Name) {
        if ($AppSettings."$Property" -eq $null) { $AppSettings."$Property" = @() }
    }

    # Add Application Settings Objects
    $ApplicationSettings = New-Object -TypeName PSObject
    $ApplicationSettings | Add-Member -MemberType NoteProperty -Name version -Value $SetupParameters.navVersion
    $ApplicationSettings | Add-Member -MemberType NoteProperty -Name locale -Value $SetupParameters.navSolution
    $AppSettings | Add-Member -MemberType NoteProperty -Name application -Value $ApplicationSettings

    Set-Content -Path $AppJsonPath -Value ($AppSettings | ConvertTo-Json)
}

    