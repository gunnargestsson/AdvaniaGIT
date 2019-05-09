function Get-FirstCompanyName
    {
        param(
            $SQLServer,
            $SQLDb
        )
        $CompanyName = Get-SQLCommandResult -Server $SQLServer -Database $SQLDb -Command "select TOP 1 [Name] from [Company]" -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword
        return $CompanyName.Name
    }
