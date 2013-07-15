# based on http://www.mikepfeiffer.net/2010/03/exchange-2010-database-statistics-with-powershell/

# Start of Settings
# Report on top mailboxes with largest dumpster size - number to report on (if <= 0, will report on whole database)
$NumLargeDeleted=10
# Is the Large Dumpster Report per Database?
$LargeDeletedReportPerDatabase=$False
# Minimum Dumpster Size to report on (in MB)
$MinDeletedSize=0
# End of Settings

# Changelog
## 2.0 : Sort by Server and Database Name
##       Include Server Name in Heading on Per DB report
##       Exchange 2007 support
##       Show mailbox size and deleted item count in report
## 2.1 : Change Comments

$Title = "Exchange 20xx Largest Dumpsters"
$Comments = "Mailboxes sorted by descending dumpster size"
$Author = "Phil Randal"
$PluginVersion = 2.1
$PluginCategory = "Exchange2010"

function Get-DatabaseLargeDumpsterMailboxes {
  $Databases = Get-MailboxDatabase -Status -ErrorAction SilentlyContinue | Sort Server,Name
  foreach($Database in $Databases) {
    If ($Database.DatabaseCreated) {
      $Details=Get-Mailbox -Database $Database -Resultsize Unlimited |
	    Get-MailboxStatistics |
	    Where {$_.totaldeleteditemsize -ge $MBSize} |
        Sort-Object TotalDeletedItemSize -descending |
		Select-Object DisplayName,
		  ItemCount,
		  @{name="Mailbox Size (MB)";exp={$_.totalitemsize.value.ToMb()}},
		  DeletedItemCount,
		  @{name="Deleted Items Size (MB)";exp={$_.totaldeleteditemsize.value.ToMb()}},
		  @{name="Total Mailbox Size (MB)";exp={$_.totalitemsize.value.ToMb()+$_.totaldeleteditemsize.value.ToMb()}} @Selection
		  
      If ($null -ne $Details) {
        $Header =  "Largest Dumpster Sizes on $($Database.Server) $($Larger)in $Database sorted by descending size"
        $script:MyReport += Get-CustomHeader $Header $Comments
	    $script:MyReport += Get-HTMLTable $Details
        $script:MyReport += Get-CustomHeaderClose
	  }
	}
  }
}

If ($2007Snapin -or $2010Snapin) {
  $Larger = ""
  $MBSize = $MinDeletedSize * 1MB
  If ($MBSize -gt 0) {
    $Larger = "larger than $MinDeletedSize MB "
  }
  $Selection = @{}
  If ($NumLargeDeleted -gt 0) {
    $Selection = @{ First = $NumLargeDeleted }
  }
  If ($LargeDeletedReportPerDatabase) {
    $Display = "None"
    Get-DatabaseLargeDumpsterMailboxes
  } Else {
    $Display = "Table"
    $Header = "Mailboxes with Dumpster Size $($Larger)sorted by descending size"
    Get-Mailbox -Resultsize Unlimited |
	  Get-MailboxStatistics |
	  Where {$_.totaldeleteditemsize -gt $MBSize} |
      Sort-Object TotalDeletedItemSize -descending |
      Select-Object DisplayName,
	    ServerName,
	    DatabaseName,
		ItemCount,
		@{name="Mailbox Size (MB)";exp={$_.totalitemsize.value.ToMb()}},
		DeletedItemCount,
		@{name="Deleted Items Size (MB)";exp={$_.totaldeleteditemsize.value.ToMb()}},
        @{name="Total Mailbox Size (MB)";exp={$_.totalitemsize.value.ToMb()+$_.totaldeleteditemsize.value.ToMb()}} @Selection
  }
}
