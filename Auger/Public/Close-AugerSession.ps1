function Close-AugerSession {
    <#
    .DESCRIPTION
        This function ends an Auger logging session. It should be run at the end of a script that sends logs through Auger.
        It will send the $AugerContext.LogFile to each log streams configured with a Summary LogType.
        It will then clear all fields in $AugerContext.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    
    begin {
        $LogSummary = Get-Content -Path ($AugerContext.LogFile.FullName)

        $EnabledSummaryLogStreams = $AugerContext.LogStreams | Where-Object -Property Enabled -eq $true | Where-Object -Property LogType -eq 'Summary'
    } process {
        Write-Verbose "Summary: $($LogSummary -join "`n")"
        :streams foreach ($stream in $EnabledSummaryLogStreams) {
            if ($PSCmdlet.ShouldProcess("$($Stream.Name)", "Send log summary")) {
                $FilteredSummary = $LogSummary
                switch ($stream.Verbosity) {
                'Error' {$FilteredSummary = $LogSummary | Select-String -Pattern '^(ERROR):.*$'}
                'Warn' {$FilteredSummary = $LogSummary | Select-String -Pattern '^((WARN)|(ERROR)):.*$'}
                'Verbose' {$FilteredSummary = $LogSummary}
                default {continue streams}
                }
                if ($FilteredSummary) {
                    # expand out multi-line logs from condensed single-line encoding and join each entry with a newline
                    $FormattedSummary = ($FilteredSummary -join "`n").Replace("\n","`n")
                    . $stream.Command ($FormattedSummary)
                }
            }
        }
    } end {
        if ($PSCmdlet.ShouldProcess('$AugerContext', 'Clear')) {
            Clear-AugerContext
        }
    }
}
