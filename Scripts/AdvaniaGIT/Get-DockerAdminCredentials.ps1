Function Get-DockerAdminCredentials {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$Message,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$DefaultUserName,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$DefaultPassword
    )
    PROCESS
    {

        if ($DefaultUserName -eq "" -and $DefaultPassword -eq "") {
            $Credential = Get-Credential -Message $Message -ErrorAction Stop
        } elseif ($DefaultPassword -eq "") {
            $Credential = Get-Credential -Message $Message -UserName $DefaultUserName -ErrorAction Stop        
        } else {
            $Credential = New-Object System.Management.Automation.PSCredential($DefaultUserName, (ConvertTo-SecureString $DefaultPassword -AsPlainText -Force))
        }
        
        return $Credential
    }        
}