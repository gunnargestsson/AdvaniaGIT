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
