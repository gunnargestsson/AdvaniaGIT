Function Set-NAVServerInstanceToNAVUserPassword
{
    param
    (
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$SetupParameters,
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$BranchSettings,
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [String]$CertificatePath,
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [String]$CertificatePassword
    )

    Load-InstanceAdminTools -SetupParameters $SetupParameters

    $Certificate = Get-Item -Path $CertificatePath
    $Cert = Import-PfxCertificate -CertStoreLocation "Cert:\LocalMachine\My" -Password (ConvertTo-SecureString -String $CertificatePassword -AsPlainText -Force) -FilePath $Certificate 
      
    Write-Host $Cert.Thumbprint
    $rsaFile = $Cert.PrivateKey.CspKeyContainerInfo.UniqueKeyContainerName
    $keyPath = "$($env:ProgramData)\Microsoft\Crypto\RSA\MachineKeys\"
    $fullPath = Join-Path $keyPath $rsaFile
    $acl = Get-Acl -Path $fullPath
    $permission = "NETWORK SERVICE","Read","Allow"
    $accessRule = new-object System.Security.AccessControl.FileSystemAccessRule $permission
    $acl.AddAccessRule($accessRule)
    Set-Acl $fullPath $acl

    Set-NAVServerConfiguration -ServerInstance $BranchSettings.instanceName -KeyName ClientServicesCredentialType -KeyValue NavUserPassword
    Set-NAVServerConfiguration -ServerInstance $BranchSettings.instanceName -KeyName ServicesCertificateThumbprint -KeyValue $Cert.Thumbprint
    Set-NAVServerInstance -ServerInstance NAV -Restart
    Sync-NAVTenant -ServerInstance $BranchSettings.instanceName -Tenant default -Mode Sync -Force 

    UnLoad-InstanceAdminTools

}