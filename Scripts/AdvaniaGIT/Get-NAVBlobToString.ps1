function Get-NAVBlobToString
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory = $true,
                ValueFromPipelineByPropertyName = $true,
        Position = 0)]
        [byte[]]$CompressedByteArray
    )

    try 
    {
        $ms = New-Object -TypeName System.IO.MemoryStream
        #Write-Host "Magic constant: $($CompressedByteArray[0]) $($CompressedByteArray[1]) $($CompressedByteArray[2]) $($CompressedByteArray[3])"
        $null = $ms.Write($CompressedByteArray,4,$CompressedByteArray.Length-4)
        $null = $ms.Seek(0,0)

        $cs = New-Object -TypeName System.IO.Compression.DeflateStream -ArgumentList ($ms, [System.IO.Compression.CompressionMode]::Decompress)
        $sr = New-Object -TypeName System.IO.StreamReader -ArgumentList ($cs)

        $t = $sr.ReadToEnd()
    }
    catch 
    {

    }
    finally 
    {
        $null = $sr.Close()
        $null = $cs.Close()
        $null = $ms.Close()
    }
    return @{
        MagicConstant = $CompressedByteArray[0, 1, 2, 3]
        Data          = $t
    }
}
