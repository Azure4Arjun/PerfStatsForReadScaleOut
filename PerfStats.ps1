param(
	[Parameter(Mandatory=$true, HelpMessage="Enter the Server Name without .database.windows.net")][string]$ServerName,
	[Parameter(Mandatory=$true)][string]$Database, 
	[Parameter(Mandatory=$true)][string]$Username, 
	[Parameter(Mandatory=$true)][string]$Password,
    [Parameter(Mandatory=$true)][string]$Path,
	[Int32]$DelayInSeconds=10,
	[switch]$AzureUSGov=$false
)

Function CreateFolder{ 
  Param( $Folder ) 
  try
   {
    $FileExists = Test-Path $Folder
    if($FileExists -eq $False)
    {
     New-Item $Folder -type directory | Out-Null
    }
   }
  catch
  {
  }
 }


# If you have included the FQDN, cut it off and use only what is before the first .
if ($ServerName -like '*.*') {
	$ServerName = $ServerName.Split('.')[0]
}

# Convert seconds to hours:minutes:seconds for WAITFOR DELAY format
$seconds = $DelayInSeconds
$minutes = 0
$hours = 0

if ($seconds -ge 60) {
	$minutes = $seconds/60
	$seconds = $seconds%60
	if ($minutes -ge 60) {
		$hours = $minutes/60
		$minutes = $minutes%60
	}
}
$delayString = $hours.ToString("00") + ":" + $minutes.ToString("00") + ":" + $seconds.ToString("00")

# Add protocol, FQDN, and Port If US gov is selected use that FQDN
$serverFQDN = "tcp:$($ServerName).database.windows.net,1433"
if ($AzureUSGov) {
	$serverFQDN = "tcp:$($ServerName).database.usgovcloudapi.net,1433"
}

$fullUsername = $Username + "@" + $ServerName

$result = $Path.SubString($Path.length - 1, 1)
if($result -ne "\")
{
 $Path=$Path+"\" 
}

$sFolderOutput = $Path+"output"

CreateFolder $sFolderOutput 

#Execute the query to obtain the details in secondary
Try
 {
  $outputFile = $sFolderOutput + "\$($ServerName)_SQL_Azure_Perf_Stats_Snapshot_BeforeCapture.txt"
  $perfStatsSnapshotScript = $Path+ "SQL_Azure_Perf_Stats_Snapshot.sql"
  Write-Host "Running the scription before capturing" 
  sqlcmd -S $serverFQDN -d $Database -U $fullUsername -P $Password -i $perfStatsSnapshotScript -o $outputFile -w 65535 -K Readonly
 }
finally
{

}

#Add the store procedure in Primary
Try
 {
   $perfStatsSnapshotScript = $Path+"SQL_Azure_Perf_Stats_Primary.sql"
   $outputFile = $sFolderOutput + "\$($ServerName)_SQL_Azure_Perf_Stats_Primary.txt"
   Write-Host "Intial DB Snapshot running in background (Primary)..."
   sqlcmd -S $serverFQDN -d $Database -U $fullUsername -P $Password -i $perfStatsSnapshotScript -o $outputFile -w 65535
 }
  finally
 {

 }

#Take data

$variableArray = 'delayvar="'+$delayString+'"'
$outputFile = $sFolderOutput +"\$($ServerName)_SQL_Azure_Perf_Stats.txt"
$perfStatsScript = $Path+"SQL_Azure_Perf_Stats.sql"
Write-Host "Capture starting, press Ctrl+C to end"
try {
	sqlcmd -v $variableArray -S $serverFQDN -d $Database -U $fullUsername -P $Password -i $perfStatsScript -o $outputFile -w 65535 -K Readonly
} finally {
  Try
   {	
    Write-Host "Capture finished. You can view the output at $($outputFile)"
     $perfStatsSnapshotScript = $Path+ "SQL_Azure_Perf_Stats_Snapshot.sql"
     $outputFile = $sFolderOutput+"\$($ServerName)_SQL_Azure_Perf_Stats_Snapshot_Startup_AfterCapture.txt"
     Write-Host "Ending DB Snapshot running in background..."
     #Execute the query to obtain the details in secondary
     sqlcmd -S $serverFQDN -d $Database -U $fullUsername -P $Password -i $perfStatsSnapshotScript -o $outputFile -w 65535 -K Readonly
   }
  finally
   {

   }
}


