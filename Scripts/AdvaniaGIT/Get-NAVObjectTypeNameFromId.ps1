<#
        .Synopsis
        Translate object type number to object type name
        .DESCRIPTION
        Function takes the ObjectType number and returns the name representing the object type
        .EXAMPLE
        Get-NAVObjectTypeNameFromId -TypeId 3
        Kamil Sacek
#>
Function Get-NAVObjectTypeNameFromId
{
    param(
        [Parameter(Mandatory = $true,ValueFromPipelinebyPropertyName = $true)]
        [int]$TypeId
    )
    switch ($TypeId)
    {
        0 
        {
            $Type = 'TableData'
        }
        1 
        {
            $Type = 'Table'
        }
        8 
        {
            $Type = 'Page'
        }
        5 
        {
            $Type = 'Codeunit'
        }
        3 
        {
            $Type = 'Report'
        }
        6 
        {
            $Type = 'XMLPort'
        }
        9 
        {
            $Type = 'Query'
        }
        7 
        {
            $Type = 'MenuSuite'
        }
    }
    Return $Type
}
