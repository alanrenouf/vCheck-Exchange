$Title = "Exchange 20xx Disconnected Mailboxes"
$Header =  "Exchange 20xx Disconnected Mailboxes"
$Comments = "Exchange 20xx Disconnected Mailboxes"
$Display = "Table"
$Author = "Phil Randal"
$PluginVersion = 2.1
$PluginCategory = "Exchange2010"

# Start of Settings
# End of Settings

# Changelog
## 2.0 : Initial release
## 2.1 : Report GUID and disconnect reason

## If you need to delete these mailboxes from the database without waiting for them to be purged normally, see
##    http://www.howexchangeworks.com/2010/09/purge-disconnected-or-soft-deleted.html

## e.g. in Exchange 2010 SP1 and later, you can type
##    Remove-StoreMailbox -Database dbxx -identity "Mailbox GUID" -MailboxState SoftDeleted


If ($2010Snapin -or $2007Snapin) {
  $exServers = Get-MailboxServer -ErrorAction SilentlyContinue |
	Where {$_.Name -match $exServerFilter } |
	Sort Name
  $disconn = @()
  ForEach ($Server in $exServers) {
    $disconn += Get-Mailboxstatistics -Server $Server |
      Where { $_.DisconnectDate -ne $null }
  }
  If ($disconn -ne $null) {
    $disconn |
      Sort DisplayName, ServerName, DatabaseName |
      Select DisplayName, ServerName, DatabaseName, DisconnectReason, DisconnectDate, MailboxGUID
	}
}
$disconn = $null
