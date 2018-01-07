Function Copy-NAVObjectFileContent
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$Path,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$Destination,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [Switch]$Force
    )

    $objectFiles = Get-Item -Path $Path 
    foreach ($objectFile in $objectFiles) {
        $fileContent = Get-Content -Path $objectFile.FullName -Encoding Oem 
        $destinationFile = Join-Path $Destination $objectFile.Name
        if ($Force) {
            Set-Content -Path $destinationFile -Value $fileContent -Encoding Oem -Force
        } else {
            Set-Content -Path $destinationFile -Value $fileContent -Encoding Oem
        }
    }
}
