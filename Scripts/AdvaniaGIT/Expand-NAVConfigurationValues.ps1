Function Expand-NAVConfigurationValues {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Configuration
    )

    $PropertyNames = @(Get-Member -InputObject $Configuration -MemberType Properties).Name


    # Add the properties, from the second object, to the first object
    foreach ($Property in $PropertyNames) {
        if (($Configuration.$Property.GetType()).Name.Contains("String")) {
          $Configuration.$Property = $ExecutionContext.InvokeCommand.ExpandString($Configuration.$Property)
        }
    }

    # Output the object
    $Configuration | select *
}
