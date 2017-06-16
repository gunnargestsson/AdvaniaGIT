Function Update-NAVInstallationParameter
{
    param( 
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$MainVersion,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$ParameterId,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$NewValue
    )
    # Read Registry binary value
    $regBinaryData = (Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\DynamicsNav$MainVersion" -Name ConfigData).ConfigData
    # Convert binary value to Xml
    [xml]$Configuration = [Text.Encoding]::UTF8.getString($regBinaryData)
    # Find and replace the SQLReplaceDb option
    $Parameter = $Configuration.Configuration.SelectSingleNode("Parameter[@Id='$ParameterId']")
    if (!($Parameter)) {
        Throw "$ParameterId not found"
    }
    $Parameter.SetAttribute("Value", $NewValue)
    # Convert Xml to binary
    $newRegBinaryData = [Text.Encoding]::UTF8.getBytes($Configuration.OuterXml)
    # Write new value to Registry
    Set-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\DynamicsNav$MainVersion" -Name ConfigData -Value $newRegBinaryData
}

