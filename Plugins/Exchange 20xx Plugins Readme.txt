Exchange Plugins for vCheck V2.1
================================

New in Exchange Plugins v2.1:
-----------------------------

Six new plugins

19 Exchange 20xx Hub Transport Message Queues
23 Exchange 20xx Services
24 Exchange 20xx Event Logs
25 Exchange 20xx Uncleared Move Requests
26 Exchange 20xx Disconnected Mailboxes
27 Exchange 20xx Forwarders

Beware, the Event Log reports can be huge and take forever to generate

Enhancements:
-------------

10 Exchange 20xx Load Snapin
   Now has an exchange server name filter pattern (used in a -match comparison) which you can specify
   It is checked wherever a server-based plugin is run
   So you can do separate reports per server (or group of servers) if you wish
   Can now select Domain view / Entire Forest view (default is Domain)

11 Exchange 20xx Basic Server Information
   Sort hotfix rollups into ascending install date order
   
12 Exchange 20xx Drive Details
   Additional "critical" threshold parameter.
   Drives with free space under this threshold will be output in red.
   
20 Exchange 20xx Largest Mailboxes
21 Exchange 20xx Largest Dumpster
22 Exchange 20xx Largest Total Size
   Implemented database name filter pattern (used in a -match comparison) which you can specify
   independently for each report

Fixes:
------

11 Exchange 20xx Basic Server Information 
   Report Server's Exchange rollups as "Unknown" of we can't connect to the remote registry

13 Exchange 2010 Database Availablility Groups
   Fix Sort keys
   
20 Exchange 20xx Largest Mailboxes
   Fix ServerName selection
   
21 Exchange 20xx Largest Dumpster
   Fix ServerName selection

22 Exchange 20xx Largest Total Size
   Fix ServerName selection
   Remove unnecessary Sort

To Do:
------
Site-based reports.  Not something I can do or test.

Archive mailbox reporting.  I don't use them, so can't test them.


New in Exchange Plugins v2.0 (released 22 March 2012):
======================================================

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

These plugins are based on ideas in http://www.stevieg.org/2011/06/exchange-environment-report/
and http://www.powershellneedfulthings.com/?page_id=281

To configure, run vCheck.ps1 -config

To select which plugins to run, use Select-Plugins.ps1 (which can be found in the latest vCheck)

The server name parameter isn't used, except in the report, so put something descriptive in there.


Plugins
=======

00 1st Plugin - Select Report Header Image
   Sets report header image
   For example, download the Exchange header from
     http://www.virtu-al.net/featured-scripts/vcheck/vcheck-headers/
   and save as vCheck\Headers\Exchange.png, and this will work out of the box
   Falls back to vCheck\Header.jpg if specified header can't be found
   
10 Exchange 20xx Load Snapin.ps1
   Loads Exchange 2010 / Exchange 2007 powershel snapin
   
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
   
19 Exchange 20xx Hub Transport Message Queues
   Report on Hub Transport Message Queues

20 Exchange 20xx Largest Mailboxes.ps1
   Report on largest mailboxes by Mailbox size
   
21 Exchange 20xx Largest Dumpster.ps1
   Report on largest mailboxes by Dumpster (deleted items) size

22 Exchange 20xx Largest Total Size.ps1
   Report on largest mailboxes by Total size (Mailbox + Dumpster)
   
For each of the above three reports, you can report on the top n mailboxes by size
either across organisation or per DB, and you can also specify a threshold size to
report on.

You can also use a regular expression match to report on a subset of databases.

For obvious reasons, I wouldn't advise reporting on all mailboxes without
a non-zero threshold

23 Exchange 20xx Services
   Report on Exchange-related services
   Either full list or a report on unexpected service state
   
24 Exchange 20xx Event Logs
   Report on Exchange Server Event Logs
   You can choose which logs to report on, and Errors and Warnings or Errors only
   And you can filter out events using regular-expression matching

25 Exchange 20xx Uncleared Move Requests
   Report on uncleared move requests

26 Exchange 20xx Disconnected Mailboxes
   List all disconnected mailboxes

27 Exchange 20xx Forwarders
   Mailboxes which forward emails to other addresses
   
Plugins for Exchange not up to date or installed.ps1
   Report on out of date / missing plugins
   
Report on Plugins.ps1
   Report on which plugins were invoked in current run
   