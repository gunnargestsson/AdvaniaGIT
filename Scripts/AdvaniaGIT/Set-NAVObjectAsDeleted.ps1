<#
        .SYNOPSIS
        Short Description
        .DESCRIPTION
        Detailed Description
        .EXAMPLE
        Set-NAVObjectAsDeleted
        explains how to use the command
        can be multiple lines
        .EXAMPLE
        Set-NAVObjectAsDeleted
        another example
        can have as many examples as you like
        Kamil Sacek
#>

function Set-NAVObjectAsDeleted
{
    param
    (
        $Server,
        $Database,
        $NAVObjectType,
        $NAVObjectID
    )
    $Result = Get-SQLCommandResult -Server $Server -Database $Database -Command "select * from Object where [Type]=$($NAVObjectType) and [ID]=$($NAVObjectID)"
    if ($Result.Count -eq 0) {
        $command = ''+
        'insert into Object (Type,[Company Name],ID,Name,Modified,Compiled,[BLOB Reference],[BLOB Size],[DBM Table No_],Date,Time,[Version List],Locked,[Locked By])'+
        "VALUES($NAVObjectType,'',$NAVObjectID,'#DELETED $($NAVObjectType):$($NAVObjectID)',0,0,'',0,0,'1753-1-1 0:00:00','1754-1-1 12:00:00','#DELETE',0,'')"

        $Result = Get-SQLCommandResult -Server $Server -Database $Database -Command $command
    } else {
        $Result = Get-SQLCommandResult -Server $Server -Database $Database -Command "update Object set [Version List] = '#DELETE', [Time]='1754-1-1 12:00:00' where [Type]=$($NAVObjectType) and [ID]=$($NAVObjectID)"
    }
}
