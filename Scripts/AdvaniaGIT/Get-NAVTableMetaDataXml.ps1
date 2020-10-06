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
        [Parameter(ValueFromPipelinebyPropertyName = $true)]
        [String]$Username,
        [Parameter(ValueFromPipelinebyPropertyName = $true)]
        [String]$Password
    )

    $dbproperty = Get-SQLCommandResult -Server $DatabaseServer -Database $DatabaseName -Username $Username -Password $Password -Command "SELECT TABLE_NAME FROM [${DatabaseName}].INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_NAME = '`$ndo`$dbproperty'"
    if ([String]::IsNullOrEmpty($dbproperty)) {
        $command = "SELECT [Metadata] FROM [Object Metadata Snapshot] WHERE [Object Type] = 1 AND [Object ID] = ${TableId}"
    } else {
        $command = "SELECT [Metadata] FROM [Object Metadata Snapshot] WHERE [Object Type] = 1 AND [Object ID] = ${TableId}"
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
