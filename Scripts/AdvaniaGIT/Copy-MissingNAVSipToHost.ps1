function Copy-MissingNAVSipToHost 
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings
    )

    if (![String]::IsNullOrEmpty($BranchSettings.dockerContainerName)) {
        try {
            if (Test-Path -Path "C:\Windows\System32\NavSip.dll") { RegSvr32 /u /s "C:\Windows\System32\NavSip.dll" }
            if (Test-Path -Path "C:\Windows\SysWow64\NavSip.dll") { RegSvr32 /u /s "C:\Windows\SysWow64\NavSip.dll" }
            if (!(Test-Path "C:\Windows\System32\NavSip.dll")) {
                Install-NAVSipCryptoProviderFromNavContainer -containerName $BranchSettings.dockerContainerName  
            }
        }
        finally {
            if (Test-Path -Path "C:\Windows\System32\NavSip.dll") { RegSvr32 /s "C:\Windows\System32\NavSip.dll" }
            if (Test-Path -Path "C:\Windows\SysWow64\NavSip.dll") { RegSvr32 /s "C:\Windows\SysWow64\NavSip.dll" }      
        }  
    }
}    
