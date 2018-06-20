function Copy-MissingNAVSipToHost 
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings
    )

    if (![String]::IsNullOrEmpty($BranchSettings.dockerContainerName)) {
        if (!(Test-Path -Path 'C:\Windows\System32\NavSip.dll')) {
            Install-NAVSipCryptoProviderFromNavContainer -containerName $BranchSettings.dockerContainerName
        }
        if (!(Test-Path -Path 'C:\Windows\System32\NavSip.dll')) {
           Copy-FileFromNavContainer -containerName $BranchSettings.dockerContainerName -containerPath 'C:\Windows\System32\NavSip.dll' -localPath 'C:\Windows\System32\NavSip.dll' 
        }
        if (!(Test-Path -Path 'C:\Windows\syswow64\NavSip.dllll')) {
           Copy-FileFromNavContainer -containerName $BranchSettings.dockerContainerName -containerPath 'C:\Windows\syswow64\NavSip.dll' -localPath 'C:\Windows\syswow64\NavSip.dll' 
        }
    }
}    
