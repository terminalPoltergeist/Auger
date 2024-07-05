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
        foreach ($stream in $EnabledSummaryLogStreams) {
            if ($PSCmdlet.ShouldProcess("$($Stream.Name)", "Send log summary")) {
                $FilteredSummary = $LogSummary
                switch ($stream.Verbosity) {
                'Error' {$FilteredSummary = $LogSummary | Select-String -Pattern '^(ERROR):.*$'}
                'Warn' {$FilteredSummary = $LogSummary | Select-String -Pattern '^((WARN)|(ERROR)):.*$'}
                'Verbose' {$FilteredSummary = $LogSummary}
                default {$FilteredSummary = $LogSummary}
                }
                . $stream.Command ($FilteredSummary -join "`n")
            }
        }
    } end {
        if ($PSCmdlet.ShouldProcess('$AugerContext', 'Clear')) {
            Clear-AugerContext
        }
    }
}
