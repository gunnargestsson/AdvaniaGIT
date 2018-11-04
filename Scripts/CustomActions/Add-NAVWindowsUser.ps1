if ($BranchSettings.dockerContainerId -gt "") {
    $Session = New-DockerSession -DockerContainerId $BranchSettings.dockerContainerId 
    Invoke-Command -Session $Session -ScriptBlock {
      param([String]$userName, [String]$instanceName)
        Import-Module (Join-Path $serviceTierFolder 'Microsoft.Dynamics.Nav.Management.psm1') -DisableNameChecking -Global -ErrorAction SilentlyContinue
        $UserExists = Get-NAVServerUser -ServerInstance $instanceName | Where-Object -Property UserName -Match "\w+\\${userName}"
        if (!($UserExists)) {
            Write-Host "Creating local user..."
            New-NAVServerUser -ServerInstance $instanceName -WindowsAccount $userName
            New-NAVServerUserPermissionSet -ServerInstance $instanceName -WindowsAccount $userName -PermissionSetId SUPER
        } else {
            Write-Host "Local user exists..."
        }
    } -ArgumentList ($env:USERNAME, $BranchSettings.instanceName)   
} else {    
    Load-InstanceAdminTools -SetupParameters $SetupParameters
    $UserExists = Get-NAVServerUser -ServerInstance $BranchSettings.instanceName | Where-Object -Property UserName -Match "\w+\\$($env:USERNAME)"
    if (!($UserExists)) {
        Write-Host "Creating local user..."
        New-NAVServerUser -ServerInstance $BranchSettings.instanceName -WindowsAccount $env:USERNAME
        New-NAVServerUserPermissionSet -ServerInstance $BranchSettings.instanceName -WindowsAccount $env:USERNAME -PermissionSetId SUPER
    } else {
        Write-Host "Local user exists..."
    }
    Initialize-NAVTestCompany -SetupParameters $SetupParameters -BranchSettings $BranchSettings -RestartService
    UnLoad-InstanceAdminTools
}