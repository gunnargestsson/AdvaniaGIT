Function Get-NAVKontoRemoteCredentials {
    PROCESS {
        $RemoteConfig = Get-NAVRemoteConfig
        $VMAdmin = Get-NAVPasswordStateUser -PasswordId $RemoteConfig.VMUserPasswordID
        if ($VMAdmin.UserName -gt "" -and $VMAdmin.Password -gt "") {
            $Credential = New-Object System.Management.Automation.PSCredential($VMAdmin.UserName, (ConvertTo-SecureString $VMAdmin.Password -AsPlainText -Force))
        } else {
            $Credential = Get-Credential -Message "Remote Login to Hosts" -ErrorAction Stop    
        }

        return $Credential
    }
}