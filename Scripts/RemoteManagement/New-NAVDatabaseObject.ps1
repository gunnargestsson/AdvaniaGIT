Function New-NAVDatabaseObject {
    param(
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$DatabaseName,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$DatabaseServerName,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$DatabaseInstanceName,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$DatabaseUserName,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$DatabasePassword
    )
    PROCESS
    {
        $NewDatabase = New-Object -TypeName PSObject
        if ($DatabaseName) {
            $NewDatabase | Add-Member -MemberType NoteProperty -Name DatabaseName -Value $DatabaseName
        } else {
            $NewDatabase | Add-Member -MemberType NoteProperty -Name DatabaseName -Value ""
        }
        if ($DatabaseServerName) {
            $NewDatabase | Add-Member -MemberType NoteProperty -Name DatabaseServerName -Value $DatabaseServerName
        } else {
            $NewDatabase | Add-Member -MemberType NoteProperty -Name DatabaseServerName -Value ""
        }
        if ($DatabaseInstanceName) {
            $NewDatabase | Add-Member -MemberType NoteProperty -Name DatabaseInstanceName -Value $DatabaseInstanceName
        } else {
            $NewDatabase | Add-Member -MemberType NoteProperty -Name DatabaseInstanceName -Value ""
        }
        if ($DatabaseUserName) {
            $NewDatabase | Add-Member -MemberType NoteProperty -Name DatabaseUserName -Value $DatabaseUserName
        } else {
            $NewDatabase | Add-Member -MemberType NoteProperty -Name DatabaseUserName -Value ""
        }
        if ($DatabasePassword) {
            $NewDatabase | Add-Member -MemberType NoteProperty -Name DatabasePassword -Value $DatabasePassword
        } else {
            $NewDatabase | Add-Member -MemberType NoteProperty -Name DatabasePassword -Value ""
        }

        Return $NewDatabase
    }
}