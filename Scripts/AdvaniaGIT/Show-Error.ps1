function Show-Error
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$ErrorMessage
    )
    if ($env:bamboo_build_working_directory) {
        Write-Error $ErrorMessage -ErrorAction Stop 
    } else {
        $a = new-object -comobject wscript.shell
        $b = $a.popup($ErrorMessage,0," This is a error from AdvaniaGIT ",48)
    }
    Write-Error "" -ErrorAction Stop | Out-Null
}