Function Get-FtpFile
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
    Write-Host "Downloading $($FtpFilePath)..."
    # Credentials
    $FTPRequest = [System.Net.FtpWebRequest]::Create("$($Server)$($FtpFilePath)")
    $FTPRequest.Credentials = New-Object System.Net.NetworkCredential($User,$Pass)
    $FTPRequest.Method = [System.Net.WebRequestMethods+FTP]::DownloadFile

    # Don't want Binary, Keep Alive unecessary.
    $FTPRequest.UseBinary = $False
    $FTPRequest.KeepAlive = $False

    $FTPResponse = $FTPRequest.GetResponse()
    $ResponseStream = $FTPResponse.GetResponseStream()
    # Create the target file on the local system and the download buffer 
    $LocalFileFile = New-Object IO.FileStream ($LocalFilePath,[IO.FileMode]::Create) 
    [byte[]]$ReadBuffer = New-Object byte[] 1024 
    # Loop through the download 
	    do { 
		    $ReadLength = $ResponseStream.Read($ReadBuffer,0,1024) 
		    $LocalFileFile.Write($ReadBuffer,0,$ReadLength) 
	    } 
	    while ($ReadLength -ne 0)
    $FTPResponse.Close()
    $LocalFileFile.Close()
}