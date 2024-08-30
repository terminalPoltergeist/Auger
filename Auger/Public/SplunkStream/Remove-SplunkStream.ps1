function Remove-SplunkStream {
    <#
    .SYNOPSIS
        Removes Splunk Streams from the AugerContext LogStreams list.
    .DESCRIPTION
        This function removes Splunk log streams from the configured LogStreams.
        There are different filter options for targeting multiple Splunk Streams to remove.
    .PARAMETER All
        Switch. Removes all Splunk Streams from the configured AugerContext Log Streams list.
    .PARAMETER Filter
        A filter string for targeting which Splunk Streams to remove.

        ex. Remove-SplunkStream -Filter "Enabled=false"
            will remove all disabled Splunk Streams

        See Docs/FilterStrings.md for full documentation.
    .NOTES
    TODO: these should be unified in a Remove-LogStream function with -Type to target specific types of streams
    #>
    param (
        [switch]
        $All,

        [string]
        $Filter
    )

    if ($All) {
        $AugerContext.LogStreams = $AugerContext.LogStreams | Where-Object -Property Name -ne 'Splunk'
        Write-Verbose "Removed all Auger SplunkStreams"
    } else {

    }
}
