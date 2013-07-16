$Title = "Exchange 20xx Uncleared Move Requests"
$Header =  "Uncleared Move Requests"
$Comments = "Uncleared Move Requests"
$Display = "Table"
$Author = "Phil Randal"
$PluginVersion = 2.0
$PluginCategory = "Exchange2010"

# Based on code in http://www.powershellneedfulthings.com/?page_id=281

# Start of Settings
# End of Settings

# Changelog
## 2.0 : Initial Release

If ($2007Snapin -or $2010Snapin) {
  Get-MoveRequest |
	Get-MoveRequestStatistics |
	Sort DisplayName |
    Select DisplayName,Status,@{Name="Total Mailbox Size (MB)";exp={$_.TotalMailBoxSize.ToMB()}},SourceDatabase,TargetDatabase,PercentComplete
}
