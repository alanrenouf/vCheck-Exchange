# Based on code in http://www.powershellneedfulthings.com/?page_id=281

# Start of Settings
# Report on MAPI Latency >= x milliseconds
$MinLatency=0
# End of Settings

# Changelog
## 2.0 : Initial Release
## 2.1 : Allow for multiple server roles on the same box

$latencyMS = @{Name="Latency (mS)";expression={[Math]::Round(([TimeSpan] $_.Latency).TotalMilliSeconds)}}
If ($2007Snapin -or $2010Snapin) {
  $exServers = Get-ExchangeServer -ErrorAction SilentlyContinue |
    Where-Object {$_.IsExchange2007OrLater -eq $True} |
	Where-Object { $_.ServerRole -like "*Mailbox*" } |
	Sort Name
  ForEach ($server in $exServers) {
    $MAPIResults = Test-MAPIConnectivity -Server $Server |
	  Sort Server,Database |
      Select Server,Database, Result, $LatencyMS, Error
	$MAPIResults |
	  Where-Object { $_."Latency (mS)" -ge $MinLatency } |
	  Select Server,Database, Result, "Latency (mS)", Error
  }
}

$Title = "Exchange 20xx MAPI Connectivity"
$Header =  "Exchange 20xx MAPI Connectivity"
$Comments = "Exchange 20xx MAPI Connectivity"
If ($MinLatency -gt 0) {
  $Header += " where Latency >= $($MinLatency)mS"
}
$Display = "Table"
$Author = "Phil Randal"
$PluginVersion = 2.1
$PluginCategory = "Exchange2010"
