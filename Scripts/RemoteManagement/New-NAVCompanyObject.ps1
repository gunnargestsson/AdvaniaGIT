Function New-NAVCompanyObject {
    param(
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$CompanyName
    )
    PROCESS
    {
        $NewCompany = New-Object -TypeName PSObject
        if ($CompanyName) {
            $NewCompany | Add-Member -MemberType NoteProperty -Name CompanyName -Value $CompanyName
        } else {
            $NewCompany | Add-Member -MemberType NoteProperty -Name CompanyName -Value ""
        }
        $NewCompany | Add-Member -MemberType NoteProperty -Name EvaluationCompany -Value $False

        Return $NewCompany
    }
}