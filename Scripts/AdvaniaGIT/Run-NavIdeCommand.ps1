function Run-NavIdeCommand
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [string] $Command,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [string] $NavServerName = "localhost",
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [string] $LogFile,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [string] $ErrText,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [string] $Username,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [string] $Password,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [Switch]$StopOnError
    )
    
    $LogFolder = (Split-Path $LogFile)
    $IdFile = Join-Path (Split-Path $LogFile) "finsqlsettings.zup"
    Remove-Item (Join-Path $LogFolder "navcommandresult.txt") -ErrorAction Ignore
    Remove-Item $logFile -ErrorAction Ignore

    $databaseInfo = "ServerName=`"$(Get-DatabaseServer -BranchSettings $BranchSettings)`",Database=`"$($BranchSettings.databaseName)`""
    if ($Username)
    {
        $databaseInfo = "ntauthentication=No`,username=`"$Username`",password=`"$Password`",$databaseInfo"
    }
    $NavIde = (Join-Path $SetupParameters.navIdePath 'finsql.exe')
    if ($BranchSettings.instanceName -eq "") {
        $finSqlCommand = "& `"$NavIde`" --% $Command`,LogFile=`"$LogFile`"`,${databaseInfo}`,id=${IdFile} | Out-Null" 
    } else {
        $navServerInfo = @"
`,NavServerName="$NavServerName"`,NavServerInstance="$($BranchSettings.instanceName)"`,NavServerManagementport=$($BranchSettings.managementServicesPort)
"@
        $finSqlCommand = "& `"$NavIde`" --% $Command`,LogFile=`"$LogFile`"`,${databaseInfo}${NavServerInfo}`,id=${IdFile} | Out-Null" 
    }
    
    Write-Verbose -Message "Running command: $finSqlCommand"
   
    $Result = Invoke-Expression -Command  $finSqlCommand | Out-Null
    if ($global:LASTEXITCODE -ne 0) {
        Write-Verbose -Message "Last Exit Code: $LastExitCode - force to 0"
        $global:LASTEXITCODE = 0
    }
      
    if (Test-Path (Join-Path $LogFolder "navcommandresult.txt"))
    {
        if (Test-Path $LogFile)
        {
            if ($StopOnError) {
                Convert-NAVLogFileToErrors -LogFile $LogFile -WarningMessage $ErrText -StopOnError
            } else {
                Convert-NAVLogFileToErrors -LogFile $LogFile -WarningMessage $ErrText
            }
        }
    }
    else
    {
        throw "${ErrText}!"
    }
}
