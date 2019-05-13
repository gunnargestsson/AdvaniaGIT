Function Set-NAVRemoteDockerContainerServerInstanceToNAVUserPassword
{
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$CertificateFileName,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$CertificatePassword
    )

    Invoke-Command -Session $Session -ScriptBlock `
    {
        param([String]$CertificateFileName, [String]$CertificatePassword)
        Invoke-ScriptInNavContainer -containerName $BranchSettings.dockerContainerName -ScriptBlock `
        {            
            param([String]$CertificateFileName, [String]$CertificatePassword)
            Import-Module AdvaniaGIT | Out-Null
            $SetupParameters = Get-GITSettings
            $BranchSettings = Get-BranchSettings -SetupParameters $SetupParameters

            $CertificatePath = Join-Path "C:\GIT" $CertificateFileName
            Set-NAVServerInstanceToNAVUserPassword -SetupParameters $SetupParameters -BranchSettings $BranchSettings -CertificatePath $CertificatePath -CertificatePassword $CertificatePassword

        } -ArgumentList ($CertificateFileName, $CertificatePassword)
    } -ArgumentList ($CertificateFileName, $CertificatePassword)
}