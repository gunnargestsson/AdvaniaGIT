Function AddTo-NAVClientInstallation
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$NAVClientInstallationPath,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$BeforeLineContaining,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$AfterLineContaining,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$InsertContent
    )

    $NAVClientInstallationContent = Get-Content -Path $NAVClientInstallationPath -Encoding UTF8
    $NewNAVClientInstallationContent = ""
    foreach ($line in $NAVClientInstallationContent) {
        if (![String]::IsNullOrEmpty($BeforeLineContaining)) {
            if ($line.contains($BeforeLineContaining)) {
                $NewNAVClientInstallationContent += $InsertContent + "`r`n"
            }
        }
        $NewNAVClientInstallationContent += $line + "`r`n"
        if (![String]::IsNullOrEmpty($AfterLineContaining)) {
            if ($line.contains($AfterLineContaining)) {
                $NewNAVClientInstallationContent += $InsertContent + "`r`n"
            }
        }
    }
    Set-Content -Path $NAVClientInstallationPath -Encoding UTF8 -Value $newNAVClientInstallationContent
}
