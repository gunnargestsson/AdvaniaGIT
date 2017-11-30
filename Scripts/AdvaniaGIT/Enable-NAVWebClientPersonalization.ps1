Function Enable-NAVWebClientPersonalization
{
    param
    (
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$BranchSettings
    )

    $wwwRootPath = (Get-Item "HKLM:\SOFTWARE\Microsoft\InetStp").GetValue("PathWWWRoot")
    $wwwRootPath = [System.Environment]::ExpandEnvironmentVariables($wwwRootPath)
    if (Test-Path (Join-Path $wwwRootPath "$($BranchSettings.instanceName)\navsettings.json")) {
        $navSettings = Get-Content -Path (Join-Path $wwwRootPath "$($BranchSettings.instanceName)\navsettings.json") -Encoding UTF8 | Out-String | ConvertFrom-Json
        $navWebSettings = $navSettings.NAVWebSettings
        if (![bool]($navWebSettings.PSObject.Properties.name -match "PersonalizationEnabled")) {
            $navWebSettings | Add-Member -MemberType NoteProperty -Name PersonalizationEnabled -Value ""
            $navSettings.NAVWebSettings = $navWebSettings
        }
        $navSettings.NAVWebSettings.PersonalizationEnabled = $true
        Set-Content -Path (Join-Path $wwwRootPath "$($BranchSettings.instanceName)\navsettings.json") -Encoding UTF8 -Value (ConvertTo-Json $navSettings)
    } else {
        [xml]$WebConfig = Get-Content -Path (Join-Path $wwwRootPath "$($BranchSettings.instanceName)\web.config") -Encoding UTF8

        if ($WebConfig.configuration.DynamicsNAVSettings.SelectSingleNode("add[@key='PersonalizationEnabled']")) {
            $WebConfig.configuration.DynamicsNAVSettings.SelectSingleNode("add[@key='PersonalizationEnabled']").Attributes["value"].Value = "true"
        } else {
            $personalizationNode = $WebConfig.CreateElement("add")
            $personalizationNode.SetAttribute("key","PersonalizationEnabled")
            $personalizationNode.SetAttribute("value","true")
            $node = $WebConfig.configuration.DynamicsNAVSettings.AppendChild($personalizationNode)        
        }
        Write-Host "Web Client Personalization Mode Enabled..."
        Set-Content -Path (Join-Path $wwwRootPath "$($BranchSettings.instanceName)\web.config") -Encoding UTF8 -Value $WebConfig.OuterXml
    }
}