function Upload-NAVLicenseToSQL
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $false,ValueFromPipelinebyPropertyName = $true,Position = 0)]
        $Server = "localhost",
        [Parameter(Mandatory = $true,ValueFromPipelinebyPropertyName = $true)]
        [String]$Database,
        [Parameter(Mandatory = $true,ValueFromPipelinebyPropertyName = $true)]
        [Byte[]]$LicenseData,
        [Parameter(ValueFromPipelinebyPropertyName = $true)]
        [String]$Username,
        [Parameter(ValueFromPipelinebyPropertyName = $true)]
        [String]$Password
      
    )
    Write-Verbose -Message "Executing SQL command to import license to SQL database"

    $SqlConnection = New-Object -TypeName System.Data.SqlClient.SqlConnection
    if ($Username) {
        $SqlConnection.ConnectionString = "Server = $Server; Database = $Database; Integrated Security = False;User ID= $Username;Password='$Password'"
    } else {
        $SqlConnection.ConnectionString = "Server = $Server; Database = $Database; Integrated Security = True"
    }
 
    $SqlCmd = New-Object -TypeName System.Data.SqlClient.SqlCommand
    $SqlCmd.Parameters.Add((New-Object System.Data.SqlClient.SqlParameter("@license", [System.Data.SqlDbType]::Image))) | Out-Null
    $SqlCmd.Parameters[0].Value = $LicenseData
    $SqlCmd.CommandText = "UPDATE [dbo].[`$ndo`$dbproperty] SET [license] = @license"
    $SqlCmd.Connection = $SqlConnection   
    $result = $SqlConnection.Open()
    $result = $SqlCmd.ExecuteNonQuery()
    $SqlConnection.Close()
    $SqlConnection.Dispose()
    return $result

}
