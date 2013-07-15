$Title = "Exchange 20xx Drive Details"
$Header = "Exchange 20xx Drive Details"
$Comments = "Exchange 20xx Drive Details"
$Display = "Table"
$Author = "Phil Randal"
$PluginVersion = 2.1
$PluginCategory = "Exchange2010"

# Based on http://www.mikepfeiffer.net/2010/03/exchange-2010-database-statistics-with-powershell/

# Start of Settings
# Report Details only for drives with <= x% free space
$ReportPercent =100
# End of Settings

# Changelog
## 2.0 : Exchange 2007 support
##       Add config option to report only on drives with <= x% free space

If ($2007Snapin -or $2010Snapin) {
  $exServers = Get-ExchangeServer -ErrorAction SilentlyContinue |
    Where-Object {$_.IsExchange2007OrLater -eq $True} |
	Sort Name
  Foreach ($s in $exServers) {
	$Target = $s.Name
    Write-CustomOut "...Collating Drive Details for $Target"
	$Disks = Get-WmiObject -ComputerName $Target Win32_Volume | sort Name
	$LogicalDrives = @()
	Foreach ($LDrive in ($Disks | Where {$_.DriveType -eq 3 -and $_.Label -ne "System Reserved"})){
	  $Details = "" | Select "Name", Label, "File System", "Capacity (GB)", "Free Space", "% Free Space"
	  $Details."Name" = $LDrive.Name
	  $Details.Label = $LDrive.Label
	  $Details."File System" = $LDrive.FileSystem
  	  $Details."Capacity (GB)" = [math]::round(($LDrive.Capacity / 1GB))
	  $Details."Free Space" = [math]::round(($LDrive.FreeSpace / 1GB))
	  $FreePercent = [Math]::Round(($LDrive.FreeSpace / 1GB) / ($LDrive.Capacity / 1GB) * 100)
	  $Details."% Free Space" = $FreePercent
	  If ($FreePercent -le $ReportPercent) {
 	    $LogicalDrives += $Details
	  }
	}
	If ($LogicalDrives.Count -gt 0) {
	  $Comments = "Drives on Exchange Server $Target"
	  If ($ReportPercent -lt 100) {
	    $Comments += " with less than $($ReportPercent)% free space"
      }
	  $Header =  $Comments
      $script:MyReport += Get-CustomHeader $Header $Comments
	  $script:MyReport += Get-HTMLTable $LogicalDrives
      $script:MyReport += Get-CustomHeaderClose
	}
  }
  $Details = $null
  $LogicalDrives = $null
  $Comments = "Exchange 20xx Drive Details"
}
