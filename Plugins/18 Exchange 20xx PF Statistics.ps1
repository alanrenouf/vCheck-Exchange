$Title = "Exchange 20xx PF Statistics"
$Header =  "Exchange Public Folder Statistics"
$Comments = "Exchange Public Folder Statistics"
$Display = "Table"
$Author = "Phil Randal"
$PluginVersion = 2.3
$PluginCategory = "Exchange2010"

# Based on Jonny's comment here: http://www.mikepfeiffer.net/2010/03/exchange-2010-database-statistics-with-powershell/

# Start of Settings
# End of Settings

# Changelog
## 2.0 : Sort by Server, Database
##       Add elementary Exchange 2007 support
## 2.1 : Add Server name filter
## 2.2 : Test for versions >= 14 to work on Exchange 2013
## 2.3 : Minor corrections

Function Get-DatabaseStatisticspublic {
  $Databases = Get-publicfolderdatabase -Status -ErrorAction SilentlyContinue |
    Where { $_.Server -match  $exServerFilter }

  If ($Databases -ne $null) {
    foreach ($Database in $Databases) {
	  If ($Database.ExchangeVersion.ExchangeBuild.Major -eq 8) {
        # Exchange 2007
	    # Use WMI (Based on code by Gary Siepser, http://bit.ly/kWWMb3)
	    $DBSize = [long](get-wmiobject cim_datafile -computername $Database.Server.Name -filter ('name=''' + $Database.edbfilepath.pathname.replace("\","\\") + '''')).filesize
	    if (!$DBSize) {
		  $DBSize = 0
	    }
	    $WhiteSpace = $null
	  } Elseif ($Database.ExchangeVersion.ExchangeBuild.Major -ge 14) {
        # Exchange 2010 and 2013
	    $DBSize = $Database.DatabaseSize.ToBytes()
	    $Whitespace = ($Database.AvailableNewMailboxSpace.ToBytes() / 1GB)
	  }

	  New-Object PSObject -Property @{
        Server = $Database.Server.Name
        Database = $Database.Name
        "Database Size (GB)" = "{0:n3}" -f ($DBSize / 1GB)
        "WhiteSpace (GB)" = $(If ($Whitespace -eq $null) { "" } Else { "{0:n3}" -f $Whitespace })
	    Mounted = $(If ($Database.Mounted) { "Yes" } Else { "No" })
	    "Circular Logging" = $(If ($Database.CircularLoggingEnabled) { "Yes" } Else { "No" })
        "Last Full Backup" = $Database.LastFullBackup
        "Last Incremental Backup" = $Database.LastIncrementalBackup
      }
    }
  }
}

If ($2007Snapin -or $2010Snapin) {
  $pf=get-DatabaseStatisticspublic
  If ($pf -ne $null) {
    $pf |
      Sort Server,Database |
	  Select Server,
        Database,
	    "Database Size (GB)",
	    "Whitespace (GB)",
	    Mounted,
	    "Circular Logging",
	    "Last Full Backup",
	    "Last Incremental Backup"
  }
}
