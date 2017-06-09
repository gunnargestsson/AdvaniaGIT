function Show-Message
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$Message
    )
    if ($SetupParameters.ExecutingBuild) {
        Write-Host $Message
    } else {
        $a = new-object -comobject wscript.shell
        $b = $a.popup($Message,0," This is a notification from AdvaniaGIT ",64)
    }
}