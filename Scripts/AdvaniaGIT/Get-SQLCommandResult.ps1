#Kamil Sacek
function Get-SQLCommandResult
{
    [CmdletBinding()]
    Param
    (
        # SQL Server
        [Parameter(Mandatory = $false,ValueFromPipelinebyPropertyName = $true,
        Position = 0)]
        $Server = "localhost",
        # SQL Database Name
        [Parameter(Mandatory = $true,ValueFromPipelinebyPropertyName = $true)]
        [String]
        $Database,
        # SQL Command to run
        [Parameter(Mandatory = $true,ValueFromPipelinebyPropertyName = $true)]
        [String]
        $Command,
        # Force return of dataset even when doesn't begin with SELECT
        [Parameter(ValueFromPipelinebyPropertyName = $true)]
        [Switch]
        $ForceDataset,
        [Parameter(ValueFromPipelinebyPropertyName = $true)]
        [String]
        $Username,
        [Parameter(ValueFromPipelinebyPropertyName = $true)]
        [String]
        $Password,
        [Parameter(ValueFromPipelinebyPropertyName = $false)]
        [String]
        $CommandTimeout = 30
      
    )
    Write-Verbose -Message "Executing SQL command: $Command"

    $SqlConnection = New-Object -TypeName System.Data.SqlClient.SqlConnection
    if ($Username) {
        $SqlConnection.ConnectionString = "Server = $Server; Database = $Database; Integrated Security = False;User ID= $Username;Password='$Password'"
    } else {
        $SqlConnection.ConnectionString = "Server = $Server; Database = $Database; Integrated Security = True"
    }
 
    $SqlCmd = New-Object -TypeName System.Data.SqlClient.SqlCommand
    $SqlCmd.CommandText = $Command
    $SqlCmd.Connection = $SqlConnection
    $SqlCmd.CommandTimeout = $CommandTimeout
    
    if (($Command.Split(' ')[0] -ilike 'select') -or ($ForceDataset)) 
    {
        $SqlAdapter = New-Object -TypeName System.Data.SqlClient.SqlDataAdapter
        $SqlAdapter.SelectCommand = $SqlCmd
 
        $DataSet = New-Object -TypeName System.Data.DataSet
        $result = $SqlAdapter.Fill($DataSet)
 
        $result = $SqlConnection.Close()
        $SqlConnection.Dispose()
 
        return $DataSet.Tables[0]
    }
    else 
    {
        $result = $SqlConnection.Open()
        $result = $SqlCmd.ExecuteNonQuery()
        $SqlConnection.Close()
        $SqlConnection.Dispose()
        return $result
    }
}
