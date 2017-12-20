function Combine-Settings
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Object1,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Object2,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$Prefix = ""

    )

    # Get a list of the properties on both objects
    $PropertyList1 = @(Get-Member -InputObject $Object1 -MemberType Properties).Name
    $PropertyList2 = Get-Member -InputObject $Object2 -MemberType Properties | Where-Object -FilterScript { $PropertyList1 -notcontains "${Prefix}$($PSItem.Name)" }

    # Add the properties, from the second object, to the first object
    foreach ($Property in $PropertyList2) {
        Write-Verbose ('Adding property: {0}' -f "${Prefix}$($Property.Name)")
        if ($Object2.$($Property.Name) -ne $null -and ($Object2.$($Property.Name).GetType()).Name.Contains("[]")) {
            Add-Member -InputObject $Object1 -Name "${Prefix}$($Property.Name)" -MemberType NoteProperty -Value @()
            $Object1."${Prefix}$($Property.Name)" = $Object2.$($Property.Name)
        } else {
            Add-Member -InputObject $Object1 -Name "${Prefix}$($Property.Name)" -MemberType NoteProperty -Value $Object2.$($Property.Name)
        }
    }

    # Output the object
    $Object1 | select *
}