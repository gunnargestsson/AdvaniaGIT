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

    # Create a nice Array of the detailed directory listing
    $StreamReader = New-Object System.IO.Streamreader $ResponseStream
    $DirListing = (($StreamReader.ReadToEnd()) -split [Environment]::NewLine)
    $StreamReader.Close()

    # Remove first two elements ( . and .. ) and last element (\n)
    If ($DirListing.Length -gt 3) {
        $DirListing = $DirListing[2..($DirListing.Length-2)]
    }

    # Close the FTP connection so only one is open at a time
    $FTPResponse.Close()
    
    # This array will hold the final result
    $FileTree = @()

    # Loop through the listings
    foreach ($CurLine in $DirListing) {

        # Split line into space separated array
        $LineTok = ($CurLine -split '\ +')

        # Get the filename (can even contain spaces)
        $CurFile = $LineTok[8..($LineTok.Length-1)]

        # Figure out if it's a directory. Super hax.
        $DirBool = $LineTok[0].StartsWith("d")
        $FileBool = $LineTok[0].StartsWith("-")

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