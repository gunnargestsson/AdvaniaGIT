function Convert-NAVLogFileToErrors
{
    Param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$LogFile,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$WarningMessage,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [Switch]$StopOnError
    )
    $Object = Get-Item -Path $LogFile
    $lines = Get-Content $LogFile
    $message = ''
    if ($WarningMessage -eq "") {
        Write-Host "WARNING: Error importing $($Object.BaseName)"
    } else {
        Write-Host "$($WarningMessage)"
    }
    foreach ($line in $lines) 
    {
        if ($line -match '\[.+\].+') 
        {
            if ($message) 
            {
                Write-Host -ForegroundColor Red "  $($message)" 
            }
            $message = ''
        }
        if ($message) 
        {
            $message += "`r`n"
        }
        $message += ($line)
    }
    if ($message) 
    {
        if ($StopOnError) {
            Write-Error -Message "$($message)" -ErrorAction Stop
        } else {
            Write-Host -ForegroundColor Red "  $($message)"
        }
    }
}
