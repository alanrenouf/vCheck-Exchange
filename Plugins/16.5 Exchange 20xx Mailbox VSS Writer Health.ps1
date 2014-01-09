# Based on Get-Exchange-Server-VSSWriters-Status.ps1

# http://smtp25.blogspot.co.uk/2014/01/use-to-retrieve-status-of-exchange.html

# Start of Settings
# End of Settings

#========================================================================
# Created with:   NotePad
# Created on  :   8/25/2013 9:21 AM
# Author      :   Benjamin Bohn
# Contributor :   Oz Casey Dedeal
# Organization:   ZtekZone
# Filename    :   Get-Exchange-Server-VSSWriters-Status
# Synopsis    :   Use to retrieve the status of the Exchange Server related VSS Writers
# Usage       :   You have to replace server names with your own servers/ You can use this script and change anything you like as professional 
#             :   courtesy please give us credits for our work http://smtp25.blogspot.com/
#              
#========================================================================

# Note: Run enable-psremoting on each of your Mailbox servers first

# function to create a new object for the next VSS writer found
function NewVSSObject {
    param( $server )
    $tempObject = New-Object -TypeName PSObject
    Add-Member -InputObject $tempObject -MemberType NoteProperty -Name "Server" -Value $server
    return $tempObject
}

# build the array of servers to search
$serverList = Get-MailBoxServer | Where { $_.Name -match $exServerFilter }

# results array
$allVSSWritersList = @()

# loop through each server in the array
foreach ( $server in $serverList ) {
    # Write-Host "Retrieving VSS status from $server......" -NoNewline

    # invoke the vssadmin utility remotely and parse the result string into an array, one element for each line
    $writers = Invoke-Command -ScriptBlock { $( vssadmin list writers ) -split "`n`r" } -ComputerName $server -ea 0
    
    # create a new object to store the results
    $px = NewVSSObject -Server $server
    
    # enumerate the results of the vssadmin
    for ( $lineNum = 0; $lineNum -lt $writers.length; $lineNum++ ) {
    
        # cleanup (trim the leading spaces)
        $line = $writers[ $lineNum ].trim()
        
        # pause reading the vssadmin results when we encounter a new writer
        if ( $line.StartsWith( "Writer name:" ) ) {
        
            # identify the writers we're interested in
            $writerName = $line.Substring( 14, $line.length-15 )
            if ( $writerName -eq 'Microsoft Exchange Writer' ) {
                Add-Member -InputObject $px -MemberType NoteProperty -Name "Writer" -Value "Information Store"
            }
            elseif ( $writerName -eq 'Microsoft Exchange Replica Writer' ) {
                Add-Member -InputObject $px -MemberType NoteProperty -Name "Writer" -Value "Replication Writer"
            }
            
            # retrieve the rest of the data that we need
            if ( $writerName -like "Microsoft Exchange*" ) {
                $state = $writers[ $lineNum + 3 ].trim()
                $error = $writers[ $lineNum + 4 ].trim()
                Add-Member -InputObject $px -MemberType NoteProperty -Name "State" -Value $state.substring( 7, $state.length-7 )
                Add-Member -InputObject $px -MemberType NoteProperty -Name "Error" -Value $error.substring( 12, $error.length-12 )
                
                # add the resulting object to the array holding all the data
                $allVSSWritersList += $px
                
                # reset the results object for the next writer
                $px = NewVSSObject -Server $server
            }
        }
    }
    # Write-Host "done"
}

# display the results
$allVSSWritersList

$Title = "Exchange 20xx Mailbox VSS Writer Health"
$Header =  "Exchange 20xx Mailbox VSS Writer Health"
$Comments = "Exchange 20xx Mailbox VSS Writer Health"
$Display = "Table"
$Author = "Phil Randal"
$PluginVersion = 1.0
$PluginCategory = "Exchange2010"
