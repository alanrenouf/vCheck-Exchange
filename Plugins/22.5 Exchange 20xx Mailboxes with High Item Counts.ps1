# Start of Settings
# Report on the largest mailboxes - number to report on (if <= 0, will report on whole database)
$NumHighItemFolders=0
# Is the High Item CountReport per Database?
$MailboxFolderItemCountReportPerDatabase=$False
# Minimum Item Counts to report on
$MinItemCount=50000
# Exchange Database Name Filter (Largest) (regular expression, to select all use '.*')
$exDBFilter=".*"
# End of Settings

# Changelog
## 0.1 'borrowed' code from Large Mailboxes by Phil Randal
## 1.0 Ready for Prod

# See http://technet.microsoft.com/en-us/library/cc535025.aspx for Microsoft's
#   recommendations about folder item counts

$Title = "Exchange 2010 Folder High Item Counts"
$Author = "Kevin Maneschyn"
$Comments = "Folders with High Item Counts"
$PluginVersion = 1.0
$PluginCategory = "Exchange2010"

function Get-FolderHighItemCounts {
  $Databases = Get-MailboxDatabase -Status -ErrorAction SilentlyContinue |
    Where { $_.Server -match $exServerFilter } |
        Where { $_.Name -match $exDBFilter } |
    Sort Server,Name
  If ($Databases) {
    foreach ($Database in $Databases) {
      If ($Database.DatabaseCreated) {
        $mbxs=Get-Mailbox -Database $Database -Resultsize Unlimited |
          Where { $_.Server -match $exServerFilter } | Select Identity
        $Details = $mbxs | Get-MailboxFolderStatistics |
            Where {($_.ItemsInFolder -ge $MinItemCount) -and ($_.FolderType -notlike "RecoverableItem*")} |
            Sort-Object -descending ItemsInFolder |
                Select @{n="Location";e={([string]$_.Identity).Substring(([string]$_.Identity).LastIndexOf('/')+1)}},
                FolderType,
                @{n="Folder Size (GB)";e={("{0:N3}" -f ($_.FolderSize.ToMB()/1024)) }},
                ItemsInFolder @Selection
        If ($null -ne $Details) {
          $Header =  "Folders with Highest Item Counts on $($Database.Server) $($Larger)in $Database sorted by descending counts"
          $script:MyReport += Get-CustomHeader $Header $Comments
          $script:MyReport += Get-HTMLTable $Details
          $script:MyReport += Get-CustomHeaderClose
        }
		$mbxs = $null
		$Details = $null
      }
    }
  }
}

If ($2007Snapin -or $2010Snapin) {
  $Larger = ""
   If ($MinItemCount -gt 0) {
    $Larger = "larger than $MinItemCount "
  }
  $Selection = @{}
  If ($NumHighItemFolders -gt 0) {
    $Selection = @{ First = $NumHighItemFolders }
  }
  If ($MailboxFolderItemCountReportPerDatabase) {
    $Display = "None"
    Get-FolderHighItemCounts
  } Else {
    $Display = "Table"
    $Header = "Folders with Item Counts $($Larger)sorted by descending size"
    $mbxs=Get-Mailbox -Resultsize Unlimited |
      Where { $_.ServerName -match $exServerFilter } | Select Identity
	$mbxs | Get-MailboxFolderStatistics |
      Where {($_.ItemsInFolder -gt $MinItemCount) -and ($_.FolderType -notlike "RecoverableItem*") } |
      Sort ItemsInFolder -descending |
      Select @{n="Location";e={([string]$_.Identity).Substring(([string]$_.Identity).LastIndexOf('/')+1)}},
             FolderType,
             @{n="Folder Size (GB)";e={("{0:N3}" -f ($_.FolderSize.ToMB()/1024)) }},
            ItemsInFolder @Selection
	$mbxs = $null
  }
}
$Comments = "Mailbox Folders sorted by descending item count"
