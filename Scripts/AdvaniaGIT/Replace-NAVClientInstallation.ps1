Function Replace-NAVClientInstallation
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$NAVClientInstallationPath,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$LineContaining,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$NewInsertContent
    )

    $NAVClientInstallationContent = Get-Content -Path $NAVClientInstallationPath -Encoding UTF8
    $NewNAVClientInstallationContent = ""
    foreach ($line in $NAVClientInstallationContent) {
        if ($line.contains($LineContaining)) {
            $NewNAVClientInstallationContent += $NewInsertContent + "`r`n"
        } else {
            $NewNAVClientInstallationContent += $line + "`r`n"
        }
    }
    Set-Content -Path $NAVClientInstallationPath -Encoding UTF8 -Value $newNAVClientInstallationContent
}
