Function New-TenantSettingsObject {
    param(
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$Id, 
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$ServerInstance,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$CustomerRegistrationNo,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$CustomerName,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$CustomerEMail,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$PasswordId,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$LicenseNo,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$ClickOnceHost
    )
    PROCESS
    {
        $TenantSettings = New-Object -TypeName PSObject
        if ($Id) {
            $TenantSettings | Add-Member -MemberType NoteProperty -Name Id -Value $Id
        } else {
            $TenantSettings | Add-Member -MemberType NoteProperty -Name Id -Value ""
        }
        if ($ServerInstance) {
            $TenantSettings | Add-Member -MemberType NoteProperty -Name ServerInstance -Value $ServerInstance
        } else {
            $TenantSettings | Add-Member -MemberType NoteProperty -Name ServerInstance -Value ""
        }
        if ($CustomerRegistrationNo) {
            $TenantSettings | Add-Member -MemberType NoteProperty -Name CustomerRegistrationNo -Value $CustomerRegistrationNo
        } else {
            $TenantSettings | Add-Member -MemberType NoteProperty -Name CustomerRegistrationNo -Value ""
        }
        if ($CustomerName) {
            $TenantSettings | Add-Member -MemberType NoteProperty -Name CustomerName -Value $CustomerName
        } else {
            $TenantSettings | Add-Member -MemberType NoteProperty -Name CustomerName -Value ""
        }
        if ($CustomerEMail) {
            $TenantSettings | Add-Member -MemberType NoteProperty -Name CustomerEMail -Value $CustomerEMail
        } else {
            $TenantSettings | Add-Member -MemberType NoteProperty -Name CustomerEMail -Value ""
        }
        if ($PasswordId) {
            $TenantSettings | Add-Member -MemberType NoteProperty -Name PasswordId -Value $PasswordId
        } else {
            $TenantSettings | Add-Member -MemberType NoteProperty -Name PasswordId -Value ""
        }
        if ($LicenseNo) {
            $TenantSettings | Add-Member -MemberType NoteProperty -Name LicenseNo -Value $LicenseNo
        } else {
            $TenantSettings | Add-Member -MemberType NoteProperty -Name LicenseNo -Value ""
        }
        if ($ClickOnceHost) {
            $TenantSettings | Add-Member -MemberType NoteProperty -Name ClickOnceHost -Value $ClickOnceHost
        } else {
            $TenantSettings | Add-Member -MemberType NoteProperty -Name ClickOnceHost -Value ""
        }
               
        return $TenantSettings
    }
}
