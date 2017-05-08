<#
        .Synopsis
        Translate object type names to integer
        .DESCRIPTION
        Function takes the ObjectType names and returns the intiger number representing the object type
        .EXAMPLE
        Get-NAVObjectTypeIdFrom Name -TypeName "Report"
        Kamil Sacek
#>
Function Get-NAVObjectTypeIdFromName
{
    param(
        [Parameter(Mandatory = $true,ValueFromPipelinebyPropertyName = $true)]
        [String]$TypeName
    )
    switch ($TypeName)
    {
        'TableData' 
        {
            $Type = 0
        }
        'Table' 
        {
            $Type = 1
        }
        'Page' 
        {
            $Type = 8
        }
        'Codeunit' 
        {
            $Type = 5
        }
        'Report' 
        {
            $Type = 3
        }
        'XMLPort' 
        {
            $Type = 6
        }
        'Query' 
        {
            $Type = 9
        }
        'MenuSuite' 
        {
            $Type = 7
        }
    }
    Return $Type
}
