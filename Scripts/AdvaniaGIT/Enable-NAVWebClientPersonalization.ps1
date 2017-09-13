Function Enable-NAVWebClientPersonalization
{
    param
    (
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$BranchSettings
    )

    $wwwRootPath = (Get-Item "HKLM:\SOFTWARE\Microsoft\InetStp").GetValue("PathWWWRoot")
    $wwwRootPath = [System.Environment]::ExpandEnvironmentVariables($wwwRootPath)
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