Function New-NAVRemoteDockerContainer
{
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [parameter(Mandatory=$true)]
        [PSObject]$BranchSetup,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$AdminPassword
    )

    Invoke-Command -Session $Session -ScriptBlock `
    {
        param([PSObject]$BranchSetup,[String]$AdminPassword)
        Start-DockerContainer -SetupParameters $SetupParameters -BranchSettings $BranchSettings -AdminPassword $AdminPassword
        $BranchSettings = Get-BranchSettings -SetupParameters $SetupParameters

        $Session = New-DockerSession -DockerContainerId $BranchSettings.DockerContainerId
        Invoke-Command -Session $Session -ScriptBlock `
        {
            param([PSObject]$BranchSetup)
            
            Import-Module AdvaniaGIT | Out-Null
            $SetupParameters = Combine-Settings $BranchSetup (Get-GITSettings)
            $SetupParameters | Add-Member "navIdePath" (Get-Item -Path 'C:\Program Files (x86)\Microsoft Dynamics NAV\*\RoleTailored Client').FullName
            $SetupParameters | Add-Member "navServicePath" (Get-Item -Path 'C:\Program Files\Microsoft Dynamics NAV\*\Service').FullName
            $SetupParameters | Add-Member "navRelease" (Get-NAVRelease -mainVersion (Split-Path -Path (Get-Item -Path 'C:\Program Files\Microsoft Dynamics NAV\*').FullName -Leaf))
            $SetupParameters | Add-Member "mainVersion" (Split-Path -Path (Get-Item -Path 'C:\Program Files\Microsoft Dynamics NAV\*').FullName -Leaf)
            $SetupParameters | Add-Member "logPath" (Join-Path "C:\Host\Log" (New-Guid))
            New-Item -Path $SetupParameters.logPath -ItemType Directory 
            Set-Content -Path "C:\AdvaniaGIT\Data\GITSettings.Json" -Value ($SetupParameters | ConvertTo-Json)
                        
        } -ArgumentList $BranchSetup
        Remove-PSSession $Session
    } -ArgumentList ($BranchSetup, $AdminPassword)
}