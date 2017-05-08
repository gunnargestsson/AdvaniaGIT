function Edit-NAVClientUserSettings
{
    [CmdletBinding()]
    param
    (
    [parameter(Mandatory=$true)]
    [xml] $ClientUserSettings,
    [parameter(Mandatory=$true)]
    [string] $KeyName,
    [parameter(Mandatory=$false)]
    [string] $NewValue
    )
    $node = $ClientUserSettings.SelectSingleNode("//configuration/appSettings/add[@key='$KeyName']")

    if ($node -eq $null)
    {
        Write-Error "The setting for key='$KeyName' cannot be found in the ClientUserSettings.config file."
        return $ClientUserSettings
    }

    # If we do not have a new Value we will not assign
    if ($newValue -ne $null) {
        Write-Verbose ("Setting '$KeyName'='$NewValue' (old value was '" + $node.GetAttribute('value') + "')")
        $node.SetAttribute('value', $NewValue)
    } else {
        Write-Verbose "New value is null. '$KeyName' is not modified."
    }
}
