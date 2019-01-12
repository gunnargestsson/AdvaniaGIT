function Install-NAVAppInDocker
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$AppFolderPath
    )
    
    $AppFolderPath = $AppFolderPath.Replace($SetupParameters.rootPath,"C:\Host")
    Invoke-Command -Session $Session -ScriptBlock {
        param([PSObject]$SetupParameters, [String]$AppFolderPath )
        if (!(Get-Module -Name Microsoft.Dynamics.Nav.Management)) { 
          Import-Module (Join-Path $serviceTierFolder 'Microsoft.Dynamics.Nav.Management.psm1') -DisableNameChecking -Global -ErrorAction SilentlyContinue
        }
        if (!(Get-Module -Name Microsoft.Dynamics.Nav.Apps.Management)) {      
          Import-Module (Join-Path $serviceTierFolder 'Microsoft.Dynamics.Nav.Apps.Management.psd1') -Global -DisableNameChecking -ErrorAction SilentlyContinue
        }
        Import-Module AdvaniaGIT -DisableNameChecking

        $BranchSettings = Get-BranchSettings -SetupParameters $SetupParameters 
        
        Get-ChildItem -Path $AppFolderPath -Filter "*.app" | Sort-Object -Property LastWriteTime | ForEach-Object {
            $ext = Publish-NAVApp -ServerInstance $BranchSettings.instanceName -Path $_.FullName -PassThru -SkipVerification
            Sync-NAVApp -ServerInstance $BranchSettings.instanceName -Name $ext.Name -Tenant default
            Install-NAVApp -ServerInstance $BranchSettings.instanceName -Name $ext.Name -Tenant default
        }
    } -ArgumentList $SetupParameters, $AppFolderPath
}