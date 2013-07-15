$Title = "Exchange 20xx Basic Server Information"
$Header ="Exchange 20xx Basic Server Information"
$Comments = "Exchange 20xx Basic Server Information"
$Display = "Table"
$Author = "Phil Randal"
$PluginVersion = 2.0
$PluginCategory = "Exchange2010"

# Based on http://www.mikepfeiffer.net/2010/03/exchange-2010-database-statistics-with-powershell/

# Start of Settings
# End of Settings

#Changelog
## 2.0 : Exchange 2007 support

If ($2007Snapin -or $2010Snapin) {
  $exServers = Get-ExchangeServer -ErrorAction SilentlyContinue |
    Where-Object {$_.IsExchange2007OrLater -eq $True} |
	Sort Name
  If ($null -ne $exServers) {
    Foreach ($exServer in $exServers) {
      $Target = $exServer.Name
      Write-CustomOut "...Collating Server Details for $Target"
#      Write-CustomOut "....getting basic computer configuration"
	  $ComputerSystem = Get-WmiObject -computername $Target Win32_ComputerSystem
	  $OperatingSystems = Get-WmiObject -computername $Target Win32_OperatingSystem
	  $TimeZone = Get-WmiObject -computername $Target Win32_Timezone
	  $Keyboards = Get-WmiObject -computername $Target Win32_Keyboard
	  $SchedTasks = Get-WmiObject -computername $Target Win32_ScheduledJob
	  $BootINI = $OperatingSystems.SystemDrive + "boot.ini"
	  $RecoveryOptions = Get-WmiObject -computername $Target Win32_OSRecoveryConfiguration
	  $exVer = $exServer.AdminDisplayVersion.Major
	  $exVersion = "Version " + $exVer + "." + $exServer.AdminDisplayVersion.Minor + " (Build " + $exServer.AdminDisplayVersion.Build + "." + $exServer.AdminDisplayVersion.Revision + ")"

#	  Write-CustomOut "....getting Exchange rollup information"
	  If ($exVer -eq "8" -or $exVer -eq "14") {
	    Switch ($exVer) {
	      "8"  { $rollUpKey = "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Installer\\UserData\\S-1-5-18\\Products\\461C2B4266EDEF444B864AD6D9E5B613\\Patches" }
		  "14" { $rollUpKey = "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Installer\\UserData\\S-1-5-18\\Products\\AE1D439464EB1B8488741FFA028E291C\\Patches" }
	    }
	  }
      $registry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $target)
      $installedRollUps = $registry.OpenSubKey($rollUpKey).GetSubKeyNames() 
 	  $Rollups = ""
	  $InstDates = ""
	  foreach ($rollUp in $installedRollUps) {
        $thisRollUp = "$rollUpKey\\$rollUp"
        $Rollups += ($thisRollUp | %{$registry.OpenSubKey($_).getvalue('DisplayName')}) + ", "
        $InstDates += ($thisRollUp | %{$registry.OpenSubKey($_).getvalue('Installed')}) + ", "
      }
	  $LBTime=$OperatingSystems.ConvertToDateTime($OperatingSystems.Lastbootuptime)
	  $Result=New-Object PSObject -Property @{
		"Computer Name" = $ComputerSystem.Name
		"Operating System" = $OperatingSystems.Caption
		"Service Pack" = $OperatingSystems.CSDVersion
		"Exchange Version" = $exVersion
		"Rollups" = $Rollups -replace '(.*), $','$1'
		"Rollup Install Dates" = $InstDates -replace '(.*), $','$1'
		"Exchange Edition" = $exServer.Edition
		"Exchange Role(s)" = $exServer.ServerRole
	  }
	  If ($null -ne $Result) {
	    $Result |
          Select "Computer Name",
		    "Operating System",
			"Service Pack",
			"Exchange Version",
			"Rollups",
			"Rollup Install Dates",
			"Exchange Edition",
			"Exchange Role(s)"
	  }
	}
  }
}
