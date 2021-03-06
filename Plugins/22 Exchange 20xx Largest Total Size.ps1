# based on http://www.mikepfeiffer.net/2010/03/exchange-2010-database-statistics-with-powershell/

# Start of Settings
# Report on the largest mailboxes by total size - number to report on (if <= 0, will report on whole database)
$NumTotalMailboxes=10
# Is the Large Mailbox by Total Size Report per Database?
$MailboxTotalReportPerDatabase=$false
# Minimum Mailbox Total Size to report on (in MB)
$MinTotalMailboxSize=0
# Exchange Database Name Filter (total) (regular expression, to select all use '.*')
$exDBFilter=".*"
# End of Settings

# Changelog
## 2.0 : New plugin to find top users of Mailbox storage including dumpster size
## 2.1 : Change comments
## 2.2 : Place comments at end of script
## 2.3 : Add Server name filter
## 2.4 : Add database name filter, remove unnecessary sort

$Title = "Exchange 20xx Largest Mailboxes by Total Size"
$Comments = "Mailboxes sorted by descending total size"
$Author = "Phil Randal"
$PluginVersion = 2.4
$PluginCategory = "Exchange2010"

function Get-DatabaseLargeTotalMailboxes {
  $Databases = Get-MailboxDatabase -Status -ErrorAction SilentlyContinue |
    Where { $_.Server -match $exServerFilter } |
	Where { $_.Name -match $exDBFilter } |
	Sort Server,Name
  foreach($Database in $Databases) {
    If ($Database.DatabaseCreated) {
      $Details=Get-Mailbox -Database $Database -Resultsize Unlimited |
	    Get-MailboxStatistics |
		Select DisplayName,
		  ItemCount,
		  @{name="Mailbox Size (MB)";exp={$_.totalitemsize.value.ToMB()}},
		  DeletedItemCount,
		  @{name="Deleted Items Size (MB)";exp={$_.totaldeleteditemsize.value.ToMB()}},
		  @{name="Total Mailbox Size (MB)";exp={$_.totalitemsize.value.ToMb()+$_.totaldeleteditemsize.value.ToMb()}}
      $Details = $Details |
	    Where {$_."Total Mailbox Size (MB)" -ge $MBSize} |
        Sort "Total Mailbox Size (MB)" -descending |
		Select DisplayName,
		  ItemCount,
		  "Mailbox Size (MB)",
		  DeletedItemCount,
		  "Deleted Items Size (MB)",
		  "Total Mailbox Size (MB)" @Selection
	  If ($null -ne $Details) {
        $Header =  "Largest Mailboxes by Total Size on $($Database.Server) $($Larger)in $Database sorted by descending size"
        $script:MyReport += Get-CustomHeader $Header $Comments
	    $script:MyReport += Get-HTMLTable $Details
        $script:MyReport += Get-CustomHeaderClose
		$Details = $null
	  }
	}
  }
}

If ($2007Snapin -or $2010Snapin) {
  $Larger = ""
  $MBSize = $MinTotalMailboxSize * 1MB
  If ($MBSize -gt 0) {
    $Larger = "larger than $MinTotalMailboxSize MB "
  }
  $Selection = @{}
  If ($NumTotalMailboxes -gt 0) {
    $Selection = @{ First = $NumTotalMailboxes }
  }
  If ($MailBoxTotalReportPerDatabase) {
    $Display = "None"
    Get-DatabaseLargeTotalMailboxes
  } Else {
    $Display = "Table"
    $Header = "Largest Mailboxes by Total Size$Larger"
    $Details = Get-Mailbox -Resultsize Unlimited |
	  Where { $_.ServerName -match $exServerFilter } |
	  Get-MailboxStatistics |
      Select DisplayName,
	    ServerName,
	    DatabaseName,
		ItemCount,
		@{name="Mailbox Size (MB)";exp={$_.totalitemsize.value.ToMB()}},
		DeletedItemCount,
		@{name="Deleted Items Size (MB)";exp={$_.totaldeleteditemsize.value.ToMB()}},
        @{name="Total Mailbox Size (MB)";exp={$_.totalitemsize.value.ToMb()+$_.totaldeleteditemsize.value.ToMb()}}
    $Details |
	  Where {$_."Total Mailbox Size (MB)" -ge $MBSize} |
      Sort "Total Mailbox Size (MB)" -descending |
	  Select DisplayName,
        DatabaseName,
		ItemCount,
		"Mailbox Size (MB)",
		DeletedItemCount,
		"Deleted Items Size (MB)",
		"Total Mailbox Size (MB)" @Selection
    $Details = $Null
  }
}
$Comments = "Mailboxes sorted by descending total size"
