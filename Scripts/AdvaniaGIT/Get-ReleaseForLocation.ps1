Function Get-ReleaseForLocation
{
    Param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$Location
    )
    PROCESS
    {
        Write-Host "Downloading CU information from Microsoft Blog..."
        Switch ($Location) {
            'US' { return 'NA' }
            'CA' { return 'NA' }
            'GB' { return 'UK' }
            Default { return $Location }
        }
    }
}