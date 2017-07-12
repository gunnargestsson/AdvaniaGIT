Function New-NAVUserObject {
    param(
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$UserName,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$FullName,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$AuthenticationEMail,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$LicenseType,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$State
    )
    PROCESS
    {
        $NewUser = New-Object -TypeName PSObject
        if ($UserName) {
            $NewUser | Add-Member -MemberType NoteProperty -Name UserName -Value $UserName
        } else {
            $NewUser | Add-Member -MemberType NoteProperty -Name UserName -Value ""
        }
        if ($FullName) {
            $NewUser | Add-Member -MemberType NoteProperty -Name FullName -Value $FullName
        } else {
            $NewUser | Add-Member -MemberType NoteProperty -Name FullName -Value ""
        }
        if ($AuthenticationEMail) {
            $NewUser | Add-Member -MemberType NoteProperty -Name AuthenticationEMail -Value $AuthenticationEMail
        } else {
            $NewUser | Add-Member -MemberType NoteProperty -Name AuthenticationEMail -Value ""
        }
        if ($LicenseType) {
            if ($LicenseType -eq "FullUser") {
                $NewUser | Add-Member -MemberType NoteProperty -Name LicenseType -Value "Full"
            } elseif ($LicenseType -eq "LimitedUser") {
                $NewUser | Add-Member -MemberType NoteProperty -Name LicenseType -Value "Limited"
            } else {
                $NewUser | Add-Member -MemberType NoteProperty -Name LicenseType -Value $LicenseType
            }
        } else {
            $NewUser | Add-Member -MemberType NoteProperty -Name LicenseType -Value "Full"
        }
        if ($State) {
            $NewUser | Add-Member -MemberType NoteProperty -Name State -Value $State
        } else {
            $NewUser | Add-Member -MemberType NoteProperty -Name State -Value "Enabled"
        }

        Return $NewUser
    }
}