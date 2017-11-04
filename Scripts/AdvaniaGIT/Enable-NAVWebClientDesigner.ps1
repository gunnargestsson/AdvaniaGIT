Function Enable-NAVWebClientDesigner
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
        $navSettings.NAVWebSettings.Designer = "true"
        Set-Content -Path (Join-Path $wwwRootPath "$($BranchSettings.instanceName)\navsettings.json") -Encoding UTF8 -Value (ConvertTo-Json $navSettings)
    } else {
        [xml]$WebConfig = Get-Content -Path (Join-Path $wwwRootPath "$($BranchSettings.instanceName)\web.config") -Encoding UTF8

        if ($WebConfig.configuration.DynamicsNAVSettings.SelectSingleNode("add[@key='designer']")) {
            $WebConfig.configuration.DynamicsNAVSettings.SelectSingleNode("add[@key='designer']").Attributes["value"].Value = "true"
        } else {
            $designerNode = $WebConfig.CreateElement("add")
            $designerNode.SetAttribute("key","designer")
            $designerNode.SetAttribute("value","true")
            $node = $WebConfig.configuration.DynamicsNAVSettings.AppendChild($designerNode)        
        }
        Write-Host "Web Client Designer Mode Enabled..."
        Set-Content -Path (Join-Path $wwwRootPath "$($BranchSettings.instanceName)\web.config") -Encoding UTF8 -Value $WebConfig.OuterXml
    }
}