function Run-NavIdeCommandWithParam
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [string] $Command,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [string] $DatabaseServer,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [string] $DatabaseName,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [switch] $NTAuthentication,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [string] $Username,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [string] $Password,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [string] $NavServerInfo,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [string] $LogFile,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
    [string] $ErrText)

    $logPath = (Split-Path $LogFile)

    Remove-Item "$logPath\navcommandresult.txt" -ErrorAction Ignore
    Remove-Item $logFile -ErrorAction Ignore

    $databaseInfo = "ServerName=`"$DatabaseServer`",Database=`"$DatabaseName`""
    
    if ($Username)
    {
        $databaseInfo = "ntauthentication=No`,username=`"$Username`",password=`"$Password`",$databaseInfo"
    }
    #Write-InfoMessage -Message "RunNavIdeCommand1:$NavIde"
    $NavIde=(Get-NavIde)
    #Write-InfoMessage -Message "RunNavIdeCommand2:$NavIde"

    $finSqlCommand = "& `"$NavIde`" --% $Command`,LogFile=`"$LogFile`"`,${databaseInfo}${NavServerInfo} | Out-Null" 

    Write-Verbose "Running command: $finSqlCommand"
   
    $Result = Invoke-Expression -Command  $finSqlCommand | Out-Null
    if ($global:LASTEXITCODE -ne 0) {
        Write-Verbose "Last Exit Code: $LastExitCode - force to 0"
        $global:LASTEXITCODE = 0
    }
      
    if (Test-Path "$logPath\navcommandresult.txt")
    {
        if (Test-Path $LogFile)
        {
            #throw "${ErrorText}: $(Get-Content $LogFile -Raw)" -replace "`r[^`n]","`r`n"
            if ($env:BUILD_REPOSITORY_PROVIDER)
            {
                Convert-NAVLogFileToErrors $LogFile
            } else {
                Convert-NAVLogFileToErrors $LogFile
            }
        }
    }
    else
    {
        throw "${ErrorText}!"
    }
}

