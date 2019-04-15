Function Get-FtpDirectory
(
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [String]$Server,
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyName=$true)]
    [String]$User,
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyName=$true)]
    [String]$Pass,
    [Parameter(Mandatory=$False, ValueFromPipelineByPropertyName=$true)]
    [String]$Directory
)

{
    
    # Credentials
    $FTPRequest = [System.Net.FtpWebRequest]::Create("$($Server)$($Directory)")
    $FTPRequest.Credentials = New-Object System.Net.NetworkCredential($User,$Pass)
    $FTPRequest.Method = [System.Net.WebRequestMethods+FTP]::ListDirectoryDetails

    # Don't want Binary, Keep Alive unecessary.
    $FTPRequest.UseBinary = $False
    $FTPRequest.KeepAlive = $False

    $FTPResponse = $FTPRequest.GetResponse()
    $ResponseStream = $FTPResponse.GetResponseStream()
    $BannerMessage = $FTPResponse.BannerMessage

    # Create a nice Array of the detailed directory listing
    $StreamReader = New-Object System.IO.Streamreader $ResponseStream
    $DirListing = (($StreamReader.ReadToEnd()) -split [Environment]::NewLine)
    $StreamReader.Close()

    # Close the FTP connection so only one is open at a time
    $FTPResponse.Close()
    
    # This array will hold the final result
    $FileTree = @()

    # Loop through the listings
    foreach ($CurLine in $DirListing) {
        if ($BannerMessage.Contains("220 Welcome to Advania")) {
            # Split line into space separated array
            $LineTok = ($CurLine -split '\ +')

            # Get the filename (can even contain spaces)
            $CurFile = $LineTok[8..($LineTok.Length-1)]

            # Figure out if it's a directory. Super hax.
            $DirBool = $LineTok[0].StartsWith("d")
            $FileBool = $LineTok[0].StartsWith("-")
        }
        if ($BannerMessage.Contains("220 Microsoft FTP Service")) {
            # Extract filename from listing format for microsoft ftp Service
            $CurFile = $CurLine[39..($CurLine.Length-1)] -join ''
            $DirBool = $CurLine.Contains('<DIR>');
            $FileBool = !$DirBool
        }
        # Determine what to do next (file or dir?)
        If ($DirBool) {
            # Recursively traverse sub-directories
            $SubDirectory = (Get-FtpDirectory -Server $Server -User $User -Pass $Pass -Directory "$($Directory)$($CurFile)/")
            $FileTree += $SubDirectory
        } ElseIf ($FileBool) {
            # Add the output to the file tree
            $FileTree += "$($Directory)$($CurFile)"
        }
    }
    
    Return $FileTree

}