Function Read-XlsFile
{
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$XlsFilePath,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SheetNo = 1,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$StartRow = 1,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$StartCol = 1
    )
    BEGIN
    {
        $xlCellTypeLastCell = 11
    }
    PROCESS
    {        
        $excel=new-object -com excel.application
        $wb=$excel.workbooks.open($XlsFilePath)

        $header = @()
        $sh=$wb.Sheets.Item($SheetNo)
        $endColumn = $sh.UsedRange.SpecialCells($xlCellTypeLastCell).Column
        $rangeAddress=$sh.Cells.Item($StartRow,$StartCol).Address() + ":" +$sh.Cells.Item($StartRow,$endColumn).Address()
        $col = $StartCol
        $sh.Range($rangeAddress).Value2 | foreach {
            $header += @{"Column" = $col; "Value" = $_}
            $col ++
        }

        $StartTime = Get-Date

        $endRow=$sh.UsedRange.SpecialCells($xlCellTypeLastCell).Row
        $xlsContent = @()
        for ($row=$StartRow+1;$row -le $endRow;$row++) {
            $xlsLine = New-Object -TypeName PSObject
            $xlsLine | Add-Member -MemberType NoteProperty -Name "RowNo" -Value $row
            for ($col=$StartCol;$col -le $endColumn;$col++) {
                $xlsLine | Add-Member -MemberType NoteProperty -Name ($header | Where-Object -Property Column -eq $col).Value -Value $sh.Cells.Item($row,$col).Value2
            }  
            $xlsContent += $xlsLine
            $NowTime = Get-Date
            $TimeSpan = New-TimeSpan $StartTime $NowTime
            $percent = $row / $endRow
            $remtime = $TimeSpan.TotalSeconds / $percent * (1-$percent)
            if (($row % 10) -eq 0) {
                Write-Progress -Status "Reading $row of $endRow" -Activity 'Reading Excel Document...' -PercentComplete ($percent*100) -SecondsRemaining $remtime
            }
        }
        return $xlsContent
    }
}
     