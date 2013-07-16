$Title = "Exchange 2010 Active DB Not on Preferred Server"
$Header =  "Exchange 2010 Active DB Not on Preferred Server"
$Comments = "Exchange 2010 Active DB Not on Preferred Server"
$Display = "Table"
$Author = "Phil Randal"
$PluginVersion = 2.3
$PluginCategory = "Exchange2010"

# Start of Settings
# End of Settings

# Changelog
## 2.0 : Initial release
## 2.1 : Simplify code
## 2.2 : Add server name filter
## 2.3 : Allow Exchange version 15

Function GetDBActivation() {
  $DBs=Get-MailboxServer -ErrorAction SilentlyContinue |
    Where { $_.AdminDisplayVersion -match "Version (14|15)" -and $_.Name -match $exServerFilter } |
	Sort Name |
	Get-MailboxDatabase |
	Sort Identity -Unique |
	Select Identity, Server, ActivationPreference
  ForEach ($DB in $DBs) {
    $ServerName=$DB.Server.Name
    $A = $DB.ActivationPreference | Where { $_.Value -eq 1 }
    If ($A) {
	  $PrefServer = $A.Key.Name
	  If ($ServerName -ne $PrefServer ) {
        New-Object PSObject -Property @{
          Database = $DB.Identity
	      Server = $ServerName
          "Preferred Server" = $PrefServer
		}
      }
	}
  }
}

If ($2010Snapin) {
  GetDBActivation | Select Database, Server, "Preferred Server"
}
