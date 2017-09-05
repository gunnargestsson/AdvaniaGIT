Function Enable-NAVWebServices3
{
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters
    )
    $configPaths = @()
    $configPaths += Join-Path $SetupParameters.navServicePath "Microsoft.Dynamics.Nav.Server.exe.config"
    $configPaths += Join-Path $SetupParameters.navIdePath "Microsoft.Dynamics.Nav.Client.exe.config"
    foreach ($configPath in $configPaths) {
        if (Test-Path $configPath) {
            [xml]$config = Get-Content -Path $configPath -Encoding UTF8
            $config.PreserveWhitespace = $true

            if (!$config.configuration.configSections.SelectSingleNode("section[@name='microsoft.web.services3']")) {
                $webServices = $config.CreateElement("section")
                $webServices.SetAttribute("name","microsoft.web.services3")
                $webServices.SetAttribute("type","Microsoft.Web.Services3.Configuration.WebServicesConfiguration, Microsoft.Web.Services3")
                $node = $config.configuration.configSections.AppendChild($webServices)        
            }
            if (!$config.configuration.SelectSingleNode("microsoft.web.services3")) {
                $webServices = $config.CreateElement("microsoft.web.services3")
                $security = $config.CreateElement("security")
                $x509 = $config.CreateElement("x509")
                $x509.SetAttribute("storeLocation","CurrentUser")
                $x509.SetAttribute("verificationMode","TrustedPeopleOrChain")
                $x509.SetAttribute("allowTestRoot","true")
                $x509.SetAttribute("verifyTrust","false")
                $node = $security.AppendChild($x509)
                $node = $webServices.AppendChild($security);
                $node = $config.configuration.AppendChild($webServices)
            }
            Set-Content -Path $configPath -Encoding UTF8 -Value $config.OuterXml
        }
    }
}