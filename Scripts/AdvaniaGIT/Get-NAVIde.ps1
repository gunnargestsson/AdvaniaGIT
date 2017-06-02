function Get-NAVIde
{
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'Version which we are looking for')]
        [String]$NAVVersion
    )
    if ($NavIde) {
        #Write-InfoMessage -Message "Get-NavIde = $NavIde"
        return (Find-NAVVersion -Path $NavIde -Version $NAVVersion)
    }
    if (!$env:NAVIdePath) 
    {
        #Write-InfoMessage -Message "Get-NavIde = 'c:\Program Files (x86)\Microsoft Dynamics NAV\80\RoleTailored Client\finsql.exe'"
        return (Find-NAVVersion -Path 'c:\Program Files (x86)\Microsoft Dynamics NAV\100\RoleTailored Client\finsql.exe' -Version $NAVVersion)
    }
    #Write-InfoMessage -Message "Get-NavIde = $((Join-Path -Path $env:NAVIdePath -ChildPath 'finsql.exe'))"
    return (Find-NAVVersion -Path (Join-Path -Path $env:NAVIdePath -ChildPath 'finsql.exe') -Version $NAVVersion)
}
