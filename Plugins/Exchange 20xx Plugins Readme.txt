Exchange Plugins for vCheck V2
==============================

New in Exchange Plugins v2.0:

Exchange 2007 support

Report on drives with <= x% free space

MAPI Latency report where latency is above user specified threshold

Active DB not mounted on preferred server report

Various bug fixes and code cleanups

All the plugins have been renumbered into a more logical order

Plus, a bonus plugin to select (via vCheck.ps1 -config) the report header image

Added plugin "22 Exchange 20xx Largest Mailboxes by Total Size", like 20 and 21,
but sorted by the sum of mailbox and dumpster sizes

-------------------------------------------------------------------------------------

00 1st Plugin - Select Report Header Image
   Sets report header image
   For example, download the Exchange header from
     http://www.virtu-al.net/featured-scripts/vcheck/vcheck-headers/
   and save as vCheck\Headers\Exchange.png, and this will work out of the box
   Falls back to vCheck\Header.jpg if specified header can't be found
   
10 Exchange 20xx Load Snapin.ps1
   Loads Exchange 2007 / Exchange 2010 powershel snapin
   
11 Exchange 20xx Basic Server Information.ps1
   Basic Exchange server info: OS & Service pack, Exchange version, hotfix rollups,
   Exchange Edition and Roles
   
12 Exchange 20xx Drive Details.ps1
   Drive details for each of the Exchange servers.  Can be configured to report only
   on drives with less than a specified percentage free space
   
13 Exchange 2010 Database Availablility Groups.ps1
   Basic info about your DAG groups - Exchange 2010 only
   
14 Exchange 20xx DB Statistics.ps1
   Database statistics - number of mailboxes, sizes, circular logging, and last
   backup dates
   
15 Exchange 2010 DB Status.ps1
   Database status info

16 16 Exchange 2010 Active DB not on Preferred Server .ps1
   Reports on databases not mounted on their preferred servers
   
17 Exchange 20xx MAPI Connectivity.ps1
   List MAPI connectivity latencies - can be configured to only report on latencies
   above a specified level
   
18 Exchange 20xx PF Statistics.ps1
   Public Folder stats
   
20 Exchange 20xx Largest Mailboxes.ps1
   Report on largest mailboxes by Mailbox size
   
21 Exchange 20xx Largest Dumpster.ps1
   Report on largest mailboxes by Dumpster (deleted items) size

22 Exchange 20xx Largest Total Size.ps1
   Report on largest mailboxes by Total size (Mailbox + Dumpster)

For each of the above three reports, you can report on the top n mailboxes by size
either across organisation or per DB, and you can also specify a threshold size to
report on.  For obvious reasons, I wouldn't advise reporting on all mailboxes without
a non-zero threshold

Plugins for Exchange not up to date or installed.ps1
   Report on out of date / missing plugins
   
Report on Plugins.ps1
   Report on which plugins were invoked in current run
   