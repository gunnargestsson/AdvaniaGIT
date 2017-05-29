function Get-FirstCompanyName
    {
        param(
            $SQLServer,
            $SQLDb
        )
        $CompanyName = Get-SQLCommandResult -Server $SQLServer -Database $SQLDb -Command "select TOP 1 [Name] from [Company] where [Name] like 'CRONUS%'"
        return $CompanyName.Name
    }