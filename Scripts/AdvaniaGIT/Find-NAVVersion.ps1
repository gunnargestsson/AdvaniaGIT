<#
        .Synopsis
        Try to find specified version of NAV in folders on same level as passed default path
        .DESCRIPTION
        Return folder name for selected NAV version. If not found, return the passed default path
        .EXAMPLE
        Find-NAVVersion 'C:\Program Files (x86)\Microsoft Dynamics NAV\80\RoleTailored Client' '8.0.40262.0'
        .EXAMPLE
        Find-NAVVersion 'C:\Program Files\Microsoft Dynamics NAV\80\Service' '8.0.40262.0'
#>

function Find-NAVVersion
{
    param
    (
        #Default path, where to start the search
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Default path, where to start the search')]
        $path,
        #Version which we are looking for
        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Version which we are looking for')]
        $Version
    )
    if (!($Version)) {
        return $path
    }
    
    if ($path -like '*.exe') {
        $filename = (Split-Path -Path $path -Leaf)
        $path = (Split-Path -Path $path)
    }
    if (Test-Path -Path (Join-Path -Path $path -ChildPath 'Microsoft.Dynamics.Nav.Server.exe')) 
    {
        $searchfile = 'Microsoft.Dynamics.Nav.Server.exe'
    }
    if (Test-Path -Path (Join-Path -Path $path -ChildPath 'finsql.exe')) 
    {
        $searchfile = 'finsql.exe'
    } 
    Write-Verbose "Searching for version $Version in $(Split-Path (Split-Path $path))"
    $result = Split-Path (Split-Path $path) |
    Get-ChildItem -Filter $searchfile -Recurse |
    Where-Object -FilterScript {
        $_.VersionInfo.FileVersion -eq $Version
    } 
    if ($result) 
    {
        if ($result.Count -gt 1) {
            Write-Verbose "Found $($result[0].DirectoryName)"
            return (Join-Path $result[0].DirectoryName $filename)
        }
        Write-Verbose "Found $($result.DirectoryName)"
        return (Join-Path $result.DirectoryName $filename)
    }
    Write-Verbose "Not found, returning $path"
    return (Join-Path $path $filename)
}
