function Close-AugerSession {
    <#
    .DESCRIPTION
        This function ends an Auger logging session. It should be run at the end of a script that sends logs through Auger.
        It will send the $AugerContext.LogFile to each log streams configured with a Summary LogType.
        It will then clear all fields in $AugerContext.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    
    $LogSummary = Get-Content -Path ($AugerContext.LogFile.FullName) -Raw

    $EnabledLogStreams = $AugerContext.LogStreams | Where-Object -Property Enabled -eq $true

    foreach ($stream in $EnabledLogStreams) {
        if ($PSCmdlet.ShouldProcess("$($Stream.Name)", "Send log summary")) {
            if ($stream.LogType -eq 'Summary') {
                . $stream.Command $LogSummary
            }
        }
    }
}
