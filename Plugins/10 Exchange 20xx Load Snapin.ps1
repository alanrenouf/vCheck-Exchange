$Title = "Exchange 20xx Load Snapin"
$Header ="Exchange 20xx Load Snapin"
$Comments = "Exchange 20xx Load Snapin"
$Display = "None"
$Author = "Phil Randal"
$PluginVersion = 2.0
$PluginCategory = "Exchange2010"

# Based on ideas in http://www.stevieg.org/2011/06/exchange-environment-report/

# Start of Settings
# End of Settings

# Changelog
## 2.0 : Simplify to do nothing more than load Exchange snapin

# Try to load Exchange Management snapins then test if they're loaded OK
# If already loaded, load attempt will silently fail, but will still be OK
# Try Exchange 2007 snapin first; if that fails, try Exchange 2010 snapin

$null = Add-PSSnapin -Name Microsoft.Exchange.Management.PowerShell.Admin -ErrorAction SilentlyContinue
$2007snapin = Get-PSSnapin -Name Microsoft.Exchange.Management.PowerShell.Admin -ErrorAction SilentlyContinue
if (!$2007snapin) {
	$null = Add-PSSnapin -Name Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction SilentlyContinue
	$2010snapin = Get-PSSnapin -Name Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction SilentlyContinue
}
