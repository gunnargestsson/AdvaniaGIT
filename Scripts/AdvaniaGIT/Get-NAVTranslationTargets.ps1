function Get-NAVTranslationTargets
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings
    )
    if ($BranchSettings.dockerContainerId -eq "") {
        $Languages = Get-ChildItem -Path $SetupParameters.navServicePath -Filter '??-??'
    } else {
        $Languages = Invoke-ScriptInNavContainer -containerName $BranchSettings.dockerContainerName -ScriptBlock {
            $navServicePath = (Get-Item -Path 'C:\Program Files\Microsoft Dynamics NAV\*\Service').FullName
            if ($navServicePath -eq $null) {
            	$navServicePath = (Get-Item -Path 'C:\Program Files\Microsoft Dynamics 365 Business Central\*\Service').FullName
            }
            return Get-ChildItem -Path $navServicePath -Filter '??-??'
        }
    }
    return $Languages
}