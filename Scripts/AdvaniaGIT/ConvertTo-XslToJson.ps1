Function ConvertTo-XslToJson
{
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$XlsFilePath,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SheetNo = 1,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$StartRow = 1,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$StartCol = 1
    )
    $PSObject = Read-XlsFile -XlsFilePath $XlsFilePath -SheetNo $SheetNo -StartRow $StartRow -StartCol $StartCol 
    Return $PSObject | ConvertTo-Json

}