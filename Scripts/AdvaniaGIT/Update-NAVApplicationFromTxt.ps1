function Update-NAVApplicationFromTxt
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [string]$ObjectsPath,
        [Parameter(ValueFromPipelinebyPropertyName = $true)]
        [switch]$SkipDeleteCheck,
        [Parameter(ValueFromPipelinebyPropertyName = $true)]
        [switch]$MarkToDelete

    )
    $CultureInfo = [System.Globalization.CultureInfo]::GetCultureInfo((Get-Culture).Name)
    if ($SetupParameters.datetimeCulture) {
        $RepositoryCultureInfo = [System.Globalization.CultureInfo]::GetCultureInfo($SetupParameters.datetimeCulture)
    } else {
        $RepositoryCultureInfo = [System.Globalization.CultureInfo]::GetCultureInfo((Get-Culture).Name)
    }
    $Server = Get-DatabaseServer -BranchSettings $BranchSettings
    $Database = $BranchSettings.databaseName
    $FileObjects = Get-NAVApplicationObjectProperty -Source $ObjectsPath -ErrorAction Stop
    if (!$FileObjects) {
        Write-Error -Message 'Files not readed!' -ErrorAction Stop
    }
    $FileObjectsHash = $null
    $FileObjectsHash = @{}
    $i = 0
    $count = $FileObjects.Count
    $UpdatedObjects = New-Object -TypeName System.Collections.ArrayList
    $StartTime = Get-Date

    foreach ($FileObject in $FileObjects)
    {
        if (!$FileObject.Id) 
        {
            Continue
        }
        $i++
        $NowTime = Get-Date
        $TimeSpan = New-TimeSpan $StartTime $NowTime
        $percent = $i / $count
        if ($percent -gt 1) 
        {
            $percent = 1
        }
        $remtime = $TimeSpan.TotalSeconds / $percent * (1-$percent)

        if (($i % 10) -eq 0) 
        {
            if (-not $NoProgress) 
            {
                Write-Progress -Status "Processing $i of $count" -Activity 'Comparing objects...' -PercentComplete ($percent*100) -SecondsRemaining $remtime
            }
        }
        $Type = Get-NAVObjectTypeIdFromName -TypeName $FileObject.ObjectType
        $Id = $FileObject.Id
        if ($FileObject.VersionList -eq '#DELETE') 
        {
            Write-Host "$($FileObject.ObjectType) $($FileObject.Id) is deleted..."
        }
        else 
        {
            $FileObjectsHash.Add("$Type-$Id",$true)
            $NAVObject = Get-SQLCommandResult -Server $Server -Database $Database -Command "select [Type],[ID],[Version List],[Modified],[Name],[Date],[Time] from Object where [Type]=$Type and [ID]=$Id" -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword
            $FileObjectDateTime = Get-Date
            $skipObject = ([datetime]::TryParseExact("$($FileObject.Date) $($FileObject.Time)","$($RepositoryCultureInfo.DateTimeFormat.ShortDatePattern) $($RepositoryCultureInfo.DateTimeFormat.LongTimePattern)".Replace("yyyy","yy"),[System.Globalization.CultureInfo]::InvariantCulture,[System.Globalization.DateTimeStyles]::None,[ref]$FileObjectDateTime))
            if (!$skipObject) {
                $skipObject = ([datetime]::TryParseExact("$($FileObject.Date) $($FileObject.Time)","$($RepositoryCultureInfo.DateTimeFormat.ShortDatePattern) $($RepositoryCultureInfo.DateTimeFormat.LongTimePattern)",[System.Globalization.CultureInfo]::InvariantCulture,[System.Globalization.DateTimeStyles]::None,[ref]$FileObjectDateTime))
            }
            $NavObjectDateTime = Get-Date
            if ($NAVObject.Date -ne $null -and $NAVObject.Time -ne $null) {
                $skipObject = $skipObject -and ([datetime]::TryParse("$($NAVObject.Date.ToString($CultureInfo.DateTimeFormat.ShortDatePattern, $CultureInfo)) $($NAVObject.Time.ToString($CultureInfo.DateTimeFormat.LongTimePattern, $CultureInfo))",[ref]$NavObjectDateTime))
            } else {
                $skipObject = $false
            }

            if (($FileObject.Modified -eq $NAVObject.Modified -or $FileObject.Modified -eq ($NAVObject.Modified -eq 1)) -and
                ($FileObject.VersionList -eq $NAVObject.'Version List') -and
                ($FileObjectDateTime -eq $NavObjectDateTime) -and
                ($skipObject) -and
                (!$All)
            )
            {
                Write-Verbose -Message "$($FileObject.ObjectType) $($FileObject.Id) skipped..."
            }
            else 
            {
                $ObjToImport = @{
                    'Type'   = $Type
                    'ID'     = $Id
                    'FileName' = $FileObject
                }
                if ($Id -gt 0) 
                {
                    $UpdatedObjects += $ObjToImport
                    if ($All) 
                    {
                        Write-Verbose -Message "$($FileObject.ObjectType) $($FileObject.Id) forced..."
                    }
                    else 
                    {
                        if (($NAVObject -eq $null) -or ($NAVObject -eq '')) 
                        {
                            Write-Verbose -Message "$($FileObject.ObjectType) $($FileObject.Id) is new..."
                        }
                        else
                        {
                            Write-Verbose -Message "$($FileObject.ObjectType) $($FileObject.Id) differs: Modified=$($FileObject.Modified -eq $NAVObject.Modified) Version=$($FileObject.VersionList -eq $NAVObject.'Version List') Time=$($FileObject.Time.TrimStart(' ') -eq $NAVObject.Time.ToString($CultureInfo.DateTimeFormat.LongTimePattern, $CultureInfo)) Date=$($FileObject.Date -eq $NAVObject.Date.ToString($CultureInfo.DateTimeFormat.ShortDatePattern, $CultureInfo))"
                        }
                    }
                }
            }
        }
    }

    $i = 0
    $count = $UpdatedObjects.Count
    if (!$SkipDeleteCheck) 
    {
        $NAVObjects = Get-SQLCommandResult -Server $Server -Database $Database -Command 'select [Type],[ID],[Version List],[Modified],[Name],[Date],[Time] from Object where [Type]>0 and [ID]<2000000000' -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword
        $i = 0
        $count = $NAVObjects.Count
        $StartTime = Get-Date
        $NotToDeleteObjects = Invoke-Expression $SetupParameters.objectsNotToDelete

        foreach ($NAVObject in $NAVObjects)
        {
            if (!$NAVObject.ID) 
            {
                Continue
            }

            $i++
            $NowTime = Get-Date
            $TimeSpan = New-TimeSpan $StartTime $NowTime
            $percent = $i / $count
            $remtime = $TimeSpan.TotalSeconds / $percent * (1-$percent)

            if (-not $NoProgress) 
            {
                Write-Progress -Status "Processing $i of $count" -Activity 'Checking deleted objects...' -PercentComplete ($i / $count*100) -SecondsRemaining $remtime
            }
            if ($NotToDeleteObjects -notcontains $NAVObject.ID)
            {
                $Type = Get-NAVObjectTypeNameFromId -TypeId $NAVObject.Type
                #$FileObject = $FileObjects | Where-Object {($_.ObjectType -eq $Type) -and ($_.Id -eq $NAVObject.ID)}
                $Exists = $FileObjectsHash["$($NAVObject.Type)-$($NAVObject.ID)"]
                if (!$Exists) 
                {
                    Write-Warning -Message "$Type $($NAVObject.ID) Should be removed from the database!"
                    if ($MarkToDelete) 
                    {
                        Set-NAVObjectAsDeleted -Server $Server -Database $Database -NAVObjectType $NAVObject.Type -NAVObjectID $NAVObject.ID
                    }
                }
            }
        }
    }

    $i = 0
    $count = $UpdatedObjects.Count
        
    $StartTime = Get-Date
    foreach ($ObjToImport in $UpdatedObjects) 
    {
        $i++
        $NowTime = Get-Date
        $TimeSpan = New-TimeSpan $StartTime $NowTime
        $percent = $i / $count
        if ($percent -gt 1) 
        {
            $percent = 1
        }
        $remtime = $TimeSpan.TotalSeconds / $percent * (1-$percent)

        if (-not $NoProgress) 
        {
            Write-Progress -Status "Importing $i of $count" -Activity 'Importing objects...' -CurrentOperation $ObjToImport.FileName.FileName -PercentComplete ($percent*100) -SecondsRemaining $remtime
        }
        if (($ObjToImport.Type -eq 7) -and ($ObjToImport.Id -lt 1050))
        {
            $Result = Get-SQLCommandResult -Server $Server -Database $Database -Command "DELETE from Object where [Type]=7 and [ID]=$($ObjToImport.Id)" -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword
        }
        Write-Verbose -Message "Importing $($ObjToImport.FileName.FileName)"
        Import-NAVApplicationGITObject -SetupParameters $SetupParameters -BranchSettings $BranchSettings -Path $ObjToImport.FileName.FileName -ImportAction Overwrite -SynchronizeSchemaChanges Force
        Invoke-PostImportCompilation -SetupParameters $SetupParameters -BranchSettings $BranchSettings -Object $ObjToImport
    }

    Write-Host -Object ''
    Write-Host -Object "Updated $($UpdatedObjects.Count) objects..."
}
