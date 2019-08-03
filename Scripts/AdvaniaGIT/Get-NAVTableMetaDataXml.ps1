function Get-NAVTableMetaDataXml
{
    [CmdletBinding()]
    [OutputType([Xml])]
    Param
    (
        [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
        [string]$DatabaseName,
        [Parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $true)]
        [string]$DatabaseServer = 'localhost',
        [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
        [int]$TableId,
        [Parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $true)]
        [switch]$Snapshot,
        [Parameter(ValueFromPipelinebyPropertyName = $true)]
        [String]$Username,
        [Parameter(ValueFromPipelinebyPropertyName = $true)]
        [String]$Password
    )

    if ($Snapshot) {
        $command = "SELECT [Metadata] FROM [Object Metadata Snapshot] WHERE [Object Type] = 1 AND [Object ID] = ${TableId}"
    } else {
        $command = "SELECT [Metadata] FROM [Object Metadata] WHERE [Object Type] = 1 AND [Object ID] = ${TableId}"
    }
    try {
        $Metadata = Get-SQLCommandResult -Server $DatabaseServer -Database $DatabaseName -Username $Username -Password $Password -Command $command
        [xml]$Xml = (Get-NAVBlobToString -CompressedByteArray $Metadata.Metadata).Data
        Return $Xml
    }
    catch {
    }
    finally {     
    }
    
}
