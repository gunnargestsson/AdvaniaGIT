function Save-NAVTestResultCsv
{
    param(
        $SQLServer,
        $SQLDb,
        $ResultTableName,
        $OutFile
    )
    $Command = "select [No_],[Test Run No_],[Codeunit ID],[Codeunit Name],[Function Name],"+`
                "[Platform],CASE [Result] WHEN 0 THEN 'Passed' WHEN 1 THEN 'Failed' WHEN 2 THEN 'Inconclusive' ELSE 'Incomplete' END as [Result],[Restore],[Execution Time],[Error Code],[Error Message],"+`
                "[File],[Call Stack],[User ID], CONVERT(VARCHAR(50),[Start Time], 127) as [Start Time2],"+`
                "CONVERT(VARCHAR(50),[Finish Time], 127) as [Finish Time2] from [$ResultTableName]"
    $SqlResult = Get-SQLCommandResult -Server $SQLServer -Database $SQLDb -Command $Command 
    $SqlResult | Export-Csv -Path $OutFile -Encoding Default -NoTypeInformation -Delimiter ";"
}
    