Function Put-FtpFile
(
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [String]$Server,
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyName=$true)]
    [String]$User,
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyName=$true)]
    [String]$Pass,
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyName=$true)]
    [String]$FtpFilePath,
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyName=$true)]
    [String]$LocalFilePath
)

{   
    Write-Host "Uploading to $($FtpFilePath)..."
    # Credentials
    $FTPRequest = [System.Net.FtpWebRequest]::Create("$($Server)$($FtpFilePath)")
    $FTPRequest.Credentials = New-Object System.Net.NetworkCredential($User,$Pass)
    $FTPRequest.Method = [System.Net.WebRequestMethods+FTP]::UploadFile

    # Don't want Binary, Keep Alive unecessary.
    $FTPRequest.UseBinary = $False
    $FTPRequest.KeepAlive = $False

    # read in the file to upload as a byte array
    $content = [System.IO.File]::ReadAllBytes($LocalFilePath)
    $FTPRequest.ContentLength = $content.Length
    # get the request stream, and write the bytes into it
    $rs = $FTPRequest.GetRequestStream()
    $rs.Write($content, 0, $content.Length)
    # be sure to clean up after ourselves
    $rs.Close()
    $rs.Dispose()
}