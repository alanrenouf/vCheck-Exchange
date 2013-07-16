$Title = "Exchange 20xx DB Statistics"
$Header =  "Exchange Database Statistics"
$Comments = "Exchange DB Statistics"
$Display = "Table"
$Author = "Phil Randal"
$PluginVersion = 2.2
$PluginCategory = "Exchange2010"

# based on http://www.mikepfeiffer.net/2010/03/exchange-2010-database-statistics-with-powershell/

# Start of Settings
# End of Settings

# Changelog
## 2.0 : Added Exchange 2007 support
##       Sort by Server, Database
##       Add last incremental backup date, Circular Logging
##       Try to deal with unmounted databases sensibly
## 2.1 : Add Server name filter
## 2.2 : Add Exchange version 15 support

function Get-MyDatabaseStatistics {
  $Databases = Get-MailboxDatabase -Status -ErrorAction SilentlyContinue |
    Where { $_.Server -match $exServerFilter } |
    Sort Server, Name
  foreach($Database in $Databases) {
    If ($Database.DatabaseCreated) {
	  $MBTot = 0
	  $DelTot = 0
	  $MBCount = 0
	  $DBMounted = $Database.Mounted
	  If ($DBMounted) {
        $MBCount = @(Get-MailboxStatistics -Database $Database).Count
        $MBSum = Get-MailboxStatistics -Database $Database |
          %{$_.TotalItemSize.value.ToBytes()} |
            Measure-Object -Sum
		$MBTot = $MBSum.Sum
        $DelSum = Get-MailboxStatistics -Database $Database |
          %{$_.TotalDeletedItemSize.value.ToBytes()} |
            Measure-Object -Sum
		$DelTot = $DelSum.Sum
	  }
      If ($MBCount -eq 0) {
	    $MBAvg = ""
		$DelAvg = ""
	  } Else {
	    $MBAvg = "{0:N3}" -f ($MBTot / $MBCount / 1MB)
		$DelAvg = "{0:N3}" -f ($DelTot / $MBCount / 1MB)
	  }
	  If ($Database.ExchangeVersion.ExchangeBuild.Major -eq 8) {
        # Exchange 2007
		# Use WMI (Based on code by Gary Siepser, http://bit.ly/kWWMb3)
		$DBSize = [long](get-wmiobject cim_datafile -computername $Database.Server.Name -filter ('name=''' + $Database.edbfilepath.pathname.replace("\","\\") + '''')).filesize
		if (!$DBSize) {
			[long]$DBSize = 0
			[long]$Whitespace = 0
		} else {
			$MailboxDeletedItemSizeB = $DelTot
			$MailBoxItemSizeB = $MBTot
			$Whitespace = ($DBSize - $MailboxItemSizeB - $MailboxDeletedItemSizeB) / 1GB
			if ($Whitespace -lt 0) { $Whitespace = 0 }
		}
		If ($DBMounted) {
		  $Whitespace = "{0:N3}" -f $Whitespace
		} Else {
		  $Whitespace = ""
		}
	  } Elseif ($Database.ExchangeVersion.ExchangeBuild.Major -ge 14) {
        # Exchange 2010
		$DBSize = $Database.DatabaseSize.ToBytes()
		$Whitespace = $Database.AvailableNewMailboxSpace.ToBytes() / 1GB
		$Whitespace = "{0:N3}" -f $Whitespace
      }
      
	  If (!$DBMounted) {
	    $MBCount = ""
	  }
      New-Object PSObject -Property @{
        Server = $Database.Server.Name
        Database = $Database.Name
        "Mailbox Count" = $MBCount
        "Database Size (GB)" = "{0:N3}" -f ($DBSize / 1GB)
        "WhiteSpace (GB)" = $Whitespace
        "Avg Mailbox Size (MB)" = $MBAvg
        "Avg Del Items Size (MB)" = $DelAvg
		Mounted = $(If ($Database.Mounted) { "Yes" } Else { "No" })
		"Circular Logging" = $(If ($Database.CircularLoggingEnabled) { "Yes" } Else { "No" })
        "Last Full Backup" = $Database.LastFullBackup
        "Last Incremental Backup" = $Database.LastIncrementalBackup
	  }
    }
  }
}

If ($2007Snapin -or $2010Snapin) {
  get-MyDatabaseStatistics |
    Sort Server, Database |
	Select Server,
      Database,
	  "Mailbox Count",
	  "Database Size (GB)",
	  "Whitespace (GB)",
	  "Avg Mailbox Size (MB)",
	  "Avg Del Items Size (MB)",
	  Mounted,
	  "Circular Logging",
	  "Last Full Backup",
	  "Last Incremental Backup"
}
