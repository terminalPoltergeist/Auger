function Remove-SlackStream {
    <#
    .SYNOPSIS
        Removes Slack Streams from the AugerContext LogStreams list.
    .DESCRIPTION
        This function removes Slack log streams from the configured LogStreams.
        There are different filter options for targeting multiple Slack Streams to remove.
    .PARAMETER All
        Switch. Removes all Slack Streams from the configured AugerContext Log Streams list.
    .PARAMETER Filter
        A filter string for targeting which Slack Streams to remove.

        ex. Remove-SlackStream -Filter "Enabled=false;webhook=https://slackwebhook123.com"
            will remove all disabled Slack Streams that send logs to the given webhook

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
        $AugerContext.LogStreams = $AugerContext.LogStreams | Where-Object -Property Name -ne 'Slack'
        Write-Verbose "Removed all Auger SlackStreams"
    } else {

    }
}
