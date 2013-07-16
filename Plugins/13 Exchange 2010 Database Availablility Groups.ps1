$Title = "Exchange 2010 DAG Info"
$Header =  "Exchange 2010 DAG Info"
$Comments = "Exchange 2010 Database Availability Group Info"
$Display = "Table"
$Author = "Phil Randal"
$PluginVersion = 2.1
$PluginCategory = "Exchange2010"

# Start of Settings
# End of Settings

# Changelog
## 2.0 : Sort by Server, Name
##       Do nothing if running under Exchange 2007 Command Shell
## 2.1 : Add Server name filter, fix sort key

function Get-DatabaseAvailabilityGroupDetails {
  $DAGs = Get-DatabaseAvailabilityGroup -Status |
    Where { $_.Servers -match $exServerFilter } |  
    Sort Name
  If ($DAGs -ne $null) {
    foreach ($DAG in $DAGs) {
      $DAGServers = ""
  	  $ds = $DAG.Servers | Sort Name
	  ForEach ($dagsrv in $ds) { $DAGServers += $dagsrv.Name + ", " }
	  $OpServers = ""
	  $os = $DAG.OperationalServers | Sort Name
	  ForEach ($dagsrv in $os) { $OpServers += $dagsrv.Name + ", " }
	  New-Object PSObject -Property @{
        Name =  $DAG.Name
        Servers = $DAGServers -replace '(.*), $','$1'
	    "Operational Servers" = $OpServers -replace '(.*), $','$1'
	    "Witness Server" = $DAG.WitnessServer
	    "Witness Dir" = $DAG.WitnessDirectory
	    "Alt Witness Server" = $DAG.AlternateWitnessServer
	    "Alt Witness Dir" = $DAG.AlternateWitnessDirectory
	  }
	}
  }
}

if ($2010snapin) {
  $dags=Get-DatabaseAvailabilityGroupDetails
  If ($dags -ne $null) {
    $dags |
      Select Name,
	    Servers,
	    "Operational Servers",
	    "Witness Server",
	    "Witness Dir",
	    "Alt Witness Server",
	    "Alt Witness Dir"
  }
}
