Function AddTo-NAVClientInstallation
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$NAVClientInstallationPath,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$BeforeLineContaining,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$InsertContent
    )

    $NAVClientInstallationContent = Get-Content -Path $NAVClientInstallationPath -Encoding UTF8
    $NewNAVClientInstallationContent = ""
    foreach ($line in $NAVClientInstallationContent) {
        if ($line.contains($beforeLineContaining)) {
            $NewNAVClientInstallationContent += $InsertContent + "`r`n"
        }
        $NewNAVClientInstallationContent += $line + "`r`n"
    }
    Set-Content -Path $NAVClientInstallationPath -Encoding UTF8 -Value $newNAVClientInstallationContent
}

$inst365 = "        function onInstallNav365Clicked() {
            if (document.SampleForm.acceptMicrosoftLicenseCheckbox.checked == false) {
                alert('You must accept the license terms to continue.');
            }
            else {
                open('365/Deployment/Microsoft.Dynamics.Nav.Client.application');
            }
        }"

AddTo-NAVClientInstallation -NAVClientInstallationPath 'C:\Program Files (x86)\Microsoft Dynamics NAV\110\ClickOnce Installer Tools\TemplateFiles\NAVClientInstallation2.html' -BeforeLineContaining "onInstallNavClicked" -InsertContent $inst365
