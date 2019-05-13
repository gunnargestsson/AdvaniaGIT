Function New-NAVRemoteDockerContainerWindowsUser
{
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [parameter(Mandatory=$false)]
        [String]$UserName
    )

    Invoke-Command -Session $Session -ScriptBlock `
    {
        param([String]$UserName)

        Invoke-ScriptInNavContainer -containerName $BranchSettings.dockerContainerName -ScriptBlock `
        {
            param([String]$UserName)
            Import-Module AdvaniaGIT | Out-Null
            $SetupParameters = Get-GITSettings
            Load-InstanceAdminTools -SetupParameters $SetupParameters
            $BranchSettings = Get-BranchSettings -SetupParameters $SetupParameters
            
            if ($UserName -eq $null -or $UserName -eq "") {
                $UserName = $env:USERNAME
            }
            
            $Users = Get-NAVServerUser -ServerInstance $BranchSettings.instanceName
            if (!($Users | Where-Object -Property UserName -imatch "\\${UserName}")) {
                Write-Host "Creating User ${UserName}..."
                New-NAVServerUser -ServerInstance $BranchSettings.instanceName -WindowsAccount $UserName
                New-NAVServerUserPermissionSet -ServerInstance $BranchSettings.instanceName -WindowsAccount ${UserName} -PermissionSetId 'SUPER'
            } else {
                Write-Host "User ${UserName} already exists."
            }
            UnLoad-InstanceAdminTools
        } -ArgumentList $UserName
    } -ArgumentList $UserName
}