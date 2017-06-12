Function Create-FtpDirectory
(
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [String]$Server,
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyName=$true)]
    [String]$User,
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyName=$true)]
    [String]$Pass,
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyName=$true)]
    [String]$FtpDirectoryPath
)

{   
    # Credentials
    $FTPRequest = [System.Net.FtpWebRequest]::Create("$($Server)$($FtpDirectoryPath)")
    $FTPRequest.Credentials = New-Object System.Net.NetworkCredential($User,$Pass)
    $FTPRequest.Method = [System.Net.WebRequestMethods+FTP]::MakeDirectory

    Try {
        $response = $FTPRequest.GetResponse();
        Write-Host Create Directory Complete, status $response.StatusDescription
        $response.Close();
    }
    Catch {
        Write-Host Directory already exists
    }
}