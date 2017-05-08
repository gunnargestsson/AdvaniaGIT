function Compile-NAVApplicationObjectMulti
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings,
        [Parameter(Mandatory = $true,ValueFromPipelinebyPropertyName = $true)]
        [String]$files,
        [Parameter(ValueFromPipelinebyPropertyName = $true)]
        [switch]$AsJob,
        # Specifies the schema synchronization behaviour. The default value is 'Yes'.
        [Parameter(ValueFromPipelinebyPropertyName = $true)]
        [ValidateSet('Yes','No','Force')]
        [string] $SynchronizeSchemaChanges = 'Yes'
    )
    
    $CPUs = (Get-WmiObject -Class Win32_Processor -Property 'NumberOfLogicalProcessors' | Select-Object -Property 'NumberOfLogicalProcessors').NumberOfLogicalProcessors
    $TextFiles = Get-ChildItem -Path "$files"
    $i = 0
    $jobs = @()

    $FilesProperty = Get-NAVApplicationObjectProperty -Source $files
    $FilesSorted = $FilesProperty | Where-Object {$_.ObjectType -ne 'Table'} | Sort-Object -Property Id
    $CountOfObjects = $FilesProperty.Count
    $Ranges = @()
    $Step = $CountOfObjects/($CPUs-1)
    $Last = 0
    #Adding one CPU for compilation of tables (preventing deadlocks?)
    $Ranges += '0..2000000999;Type=Table'
    for ($i = 0;$i -lt ($CPUs-1);$i++) 
    {
        $Ranges += "$($Last+1)..$($FilesSorted[$i*$Step+$Step-1].Id);Type=2..;Version List=<>*Test*"
        $Last = $FilesSorted[$i*$Step+$Step-1].Id
    }

    Write-Host -Object "Ranges: $Ranges"

    $StartTime = Get-Date
    foreach ($Range in $Ranges) 
    {
        $Filter = "Id=$Range"
        if ($AsJob -eq $true) 
        {
            Write-Host -Object "Compiling $Filter as Job..."
            $jobs += Compile-NAVApplicationGITObject -SetupParameters $SetupParameters -BranchSettings $BranchSettings -Filter $Filter -Recompile -AsJob -SynchronizeSchemaChanges $SynchronizeSchemaChanges
        }
        else 
        {
            Write-Host -Object "Compiling $Filter..."
            Compile-NAVApplicationGITObject -SetupParameters $SetupParameters -BranchSettings $BranchSettings -Filter $Filter -Recompile -SynchronizeSchemaChanges $SynchronizeSchemaChanges
        }
    }
    if ($AsJob -eq $true) 
    {
        Receive-Job -Job $jobs -Wait
        #Compile test objects at the end
        $TestFilter = 'Version List=*Test*'
        if ($AsJob -eq $true) 
        {
            Write-Host -Object "Compiling $TestFilter as Job..."
            $jobs += Compile-NAVApplicationGITObject -SetupParameters $SetupParameters -BranchSettings $BranchSettings -Filter $TestFilter -Recompile -AsJob -SynchronizeSchemaChanges $SynchronizeSchemaChanges
            Receive-Job -Job $jobs -Wait
        }
        else 
        {
            Write-Host -Object "Compiling $TestFilter..."
            Compile-NAVApplicationGITObject -SetupParameters $SetupParameters -BranchSettings $BranchSettings -Filter $TestFilter -Recompile -SynchronizeSchemaChanges $SynchronizeSchemaChanges
        }
    }
}
