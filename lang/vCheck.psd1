ConvertFrom-StringData @' 
   setupMsg01  = 
   setupMsg02  = Welcome to vCheck by Virtu-Al http://virtu-al.net
   setupMsg03  = =================================================
   setupMsg04  = This is the first time you have run this script or you have re-enabled the setup wizard.
   setupMsg05  =
   setupMsg06  = To re-run this wizard in the future please use vCheck.ps1 -Config
   setupMsg07  = To get usage information, please use Get-Help vCheck.ps1
   setupMsg08  =
   setupMsg09  = Please complete the following questions or hit Enter to accept the current setting
   setupMsg10  = After completing ths wizard the vCheck report will be displayed on the screen.
   setupMsg11  =
   resFileWarn = Image File not found for {0}!
   pluginInvalid = Plugin does not exist: {0}
   pluginpathInvalid = Plugin path "{0}" is invalid, defaulting to {1}
   gvInvalid   = Global Variables path invalid in job specification, defaulting to {0}
   varUndefined = Variable `${0} is not defined in GlobalVariables.ps1
   pluginActivity = Evaluating plugins
   pluginStatus = [{0} of {1}] {2}
   Complete = Complete
   pluginStart  = ..start calculating {0} by {1} v{2} [{3} of {4}]
   pluginEnd    = ..finished calculating {0} by {1} v{2} [{3} of {4}]
   repTime     = This report took {0} minutes to run all checks.
   slowPlugins = The following plugins took longer than {0} seconds to run, there may be a way to optimize these or remove them if not needed
   emailSend   = ..Sending Email
   emailAtch   = vCheck attached to this email
   HTMLdisp    = ..Displaying HTML results
'@
