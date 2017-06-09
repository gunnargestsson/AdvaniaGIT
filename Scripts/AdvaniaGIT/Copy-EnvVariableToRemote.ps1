Function Copy-EnvVariableToRemote
{
    [CmdletBinding()]
    param (
        $Session,
        $Variables
    )
    $copyvar  = {
        param ($variables)
        foreach ($var in $variables) {
        if (-not (Test-Path env:$($var.Name))) {
            Set-Item  -Path env:$($var.Name) -Value $($var.Value)
        }
        }
       }
    Invoke-Command -Session $session -ScriptBlock  $copyvar -ArgumentList @(,$Variables)
}

