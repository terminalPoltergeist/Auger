function Remove-MailStream {
    <#
    .SYNOPSIS
        Removes Mail Streams from the AugerContext LogStreams list.
    .DESCRIPTION
        This function removes MailStreams from the configured LogStreams.
        There are different filter options for targeting multiple Mail Streams to remove.
    .PARAMETER All
        Switch. Removes all Mail Streams from the configured AugerContext Log Streams list.
    .PARAMETER Filter
        A filter string for targeting which Mail Streams to remove.

        ex. Remove-MailStream -Filter "Enabled=false;Sender=user@domain.com"
            will remove all disabled Mail Streams that send logs from user@domain.com

        See Docs/FilterStrings.md for full documentation.
    #>
    param (
        [switch]
        $All,

        [string]
        $Filter
    )

    if ($All) {
        $AugerContext.LogStreams = $AugerContext.LogStreams | Where-Object -Property Name -ne 'Mail'
        Write-Verbose "Removed all Auger MailStreams"
    } else {

    }
}
