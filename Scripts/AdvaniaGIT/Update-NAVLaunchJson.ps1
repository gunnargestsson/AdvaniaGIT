Function Update-NAVLaunchJson
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$LaunchJsonPath
    )

    if (Test-Path $LaunchJsonPath) {
        $LaunchSettings = Get-Content -Path $LaunchJsonPath | Out-String | ConvertFrom-Json
        if ($BranchSettings.dockerContainerName -eq "") {
            $LaunchSettings.configurations[0].server = "http://localhost" 
        } else {
            $LaunchSettings.configurations[0].server = "http://$($BranchSettings.dockerContainerName)"
        }
        $LaunchSettings.configurations[0].serverInstance = $BranchSettings.instanceName
        if (![bool][String]::IsNullOrEmpty($LaunchSettings.configurations[0].port)) {
            $LaunchSettings.configurations[0].port = [int]$BranchSettings.developerServicesPort
        }
        if ([String]::IsNullOrEmpty($SetupParameters.dockerAuthentication)) {
            $LaunchSettings.configurations[0].authentication = "Windows"
        } else {
            switch ($SetupParameters.dockerAuthentication)
            {
                "NavUserPassword" { $LaunchSettings.configurations[0].authentication = "UserPassword" }
                default {$LaunchSettings.configurations[0].authentication = $SetupParameters.dockerAuthentication}
            }
        }

    } else {
        $LaunchSettings = New-Object -TypeName PSObject   
        # Add Text Type Objects
        $LaunchSettings | Add-Member -MemberType NoteProperty -Name version -Value "0.2.0"
        
        foreach ($Property in @(Get-Member -InputObject $LaunchSettings -MemberType NoteProperty).Name) {
            if ($LaunchSettings."$Property" -eq $null) { $LaunchSettings."$Property" = "" }
        }

        # Add Array Type Objects
        foreach ($Property in @(Get-Member -InputObject $LaunchSettings -MemberType NoteProperty).Name) {
            if ($LaunchSettings."$Property" -eq $null) { $LaunchSettings."$Property" = @() }
        }

        # Add Configuration Settings Objects
        $ConfigurationSettings = New-Object -TypeName PSObject
        $ConfigurationSettings | Add-Member -MemberType NoteProperty -Name type -Value "al"
        $ConfigurationSettings | Add-Member -MemberType NoteProperty -Name request -Value "launch"
        $ConfigurationSettings | Add-Member -MemberType NoteProperty -Name name -Value "Publish to local server"
        if ($BranchSettings.dockerContainerName -eq "") {
            $ConfigurationSettings | Add-Member -MemberType NoteProperty -Name server -Value "http://localhost"
        } else {
            $ConfigurationSettings | Add-Member -MemberType NoteProperty -Name server -Value "http://$($BranchSettings.dockerContainerName)"
        }
        [int]$developerServicesPort = $BranchSettings.developerServicesPort
        $ConfigurationSettings | Add-Member -MemberType NoteProperty -Name port -Value $developerServicesPort
        $ConfigurationSettings | Add-Member -MemberType NoteProperty -Name tenant -Value "Default"
        $ConfigurationSettings | Add-Member -MemberType NoteProperty -Name serverInstance -Value $BranchSettings.instanceName
        if ([String]::IsNullOrEmpty($SetupParameters.dockerAuthentication)) {
            $ConfigurationSettings | Add-Member -MemberType NoteProperty -Name authentication -Value "Windows"
        } else {
            $ConfigurationSettings | Add-Member -MemberType NoteProperty -Name authentication -Value $SetupParameters.dockerAuthentication
        }
        
        $LaunchSettings | Add-Member -MemberType NoteProperty -Name configurations -Value @($ConfigurationSettings)
    }
    New-Item -Path (Join-Path $SetupParameters.VSCodePath ".vscode") -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    Set-Content -Path $LaunchJsonPath -Value ($LaunchSettings | ConvertTo-Json)
}
