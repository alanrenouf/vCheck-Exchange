$Title = "Exchange 2010 DB Status"
$Header =  "Exchange 2010 DB Status"
$Comments = "Exchange 2010 DB Status"
$Display = "Table"
$Author = "Phil Randal"
$PluginVersion = 2.1
$PluginCategory = "Exchange2010"

# Start of Settings
# End of Settings

# Changelog
## 2.0 : Fixed Category
##       Fixed to not run under Exchange 2007 Management Shell
##       Sort by Server, Database

Function GetDBStatus() {
  $MBXservers=Get-MailboxServer -ErrorAction SilentlyContinue |
    Where {$_.AdminDisplayVersion.Major -eq 14} |
	Sort Server, Database |
	Select Name
  ForEach ($Server in $MBXservers) {
    $ServerName=$Server.Name
    $Status = Get-MailboxDatabaseCopyStatus -server $ServerName
    foreach($State in $Status){
      New-Object PSObject -Property @{
        DatabaseName = $state.Name
		Server = $ServerName
        Status = $state.status
	    "Copy Queue" = $state.CopyQueueLength
		"Replay Queue" = $state.ReplayQueueLength
		"Last Inspected Log Time" = $state.LastInspectedLogTime
		"Index State" = $state.ContentIndexState
	  }
	}
  }
}

If ($2010Snapin) {
  GetDBStatus |
    Sort DatabaseName |
	Select DatabaseName,Status,"Copy Queue","Replay Queue","Last Inspected Log Time","Index State"
}
