Function Copy-NAVRemoteCertificateToWorkfolder
{
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [parameter(Mandatory=$true)]
        [String]$CertificatePath,
        [parameter(Mandatory=$true)]
        [String]$Workfolder
    )

    Invoke-Command -Session $Session -ScriptBlock `
    {
        param([String]$CertificatePath, [String]$Workfolder)
        Copy-Item -Path $CertificatePath -Destination $Workfolder -Force
    } -ArgumentList ($CertificatePath, $Workfolder)

}