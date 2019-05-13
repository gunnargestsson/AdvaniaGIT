Function New-NAVRemoteDockerContainerUser
{
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$UserName,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$Password
    )

    Invoke-Command -Session $Session -ScriptBlock `
    {
        param([String]$UserName,[String]$Password)

        Invoke-ScriptInNavContainer -containerName $BranchSettings.dockerContainerName -ScriptBlock `
        {
            param([String]$UserName,[String]$Password)
            Import-Module AdvaniaGIT | Out-Null
            $SetupParameters = Get-GITSettings
            Load-InstanceAdminTools -SetupParameters $SetupParameters
            $BranchSettings = Get-BranchSettings -SetupParameters $SetupParameters
                        
            $Users = Get-NAVServerUser -ServerInstance $BranchSettings.instanceName
            if (!($Users | Where-Object -Property UserName -imatch "${UserName}")) {
                Write-Host "Creating User ${UserName}..."
                New-NAVServerUser -ServerInstance $BranchSettings.instanceName -UserName $UserName -Password (ConvertTo-SecureString -String $Password -AsPlainText -Force)
                New-NAVServerUserPermissionSet -ServerInstance $BranchSettings.instanceName -UserName ${UserName} -PermissionSetId 'SUPER'
            } else {
                Write-Host "User ${UserName} already exists."
            }
            UnLoad-InstanceAdminTools
        } -ArgumentList ($UserName, $Password)
    } -ArgumentList ($UserName, $Password)
}