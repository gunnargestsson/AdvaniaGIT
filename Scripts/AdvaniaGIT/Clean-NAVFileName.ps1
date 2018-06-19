function Clean-NAVFileName
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$FileName
    )
    $invalidChars = [System.IO.Path]::GetInvalidFileNameChars()
    $outFileName = ""
    for ($i = 0; $i -lt $FileName.Length; $i++) {
        $char = $FileName.substring($i,1)
        if ($invalidChars -contains $char) {
            $outFileName += "_"
        } else {
            $outFileName += $char
        }
    } 
    $outFileName      
}
