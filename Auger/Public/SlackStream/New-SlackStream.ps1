function New-SlackStream {
    <#
    .SYNOPSIS
        Initialize a Slack Stream.
    .DESCRIPTION
        This function initializes a Slack Stream.
        New Slack Streams are appended to the module's AugerContext LogStreams array.
    .PARAMETER SlackWebhook
        The http webhook endpoint for the Slack channel application.
    .PARAMETER LogVerbosity
        Verbosity of logs to send to this stream. Defaults to the $AugerContext default verbosity.

        Quiet - No logging.
        Error - Log fatal errors.
        Warn - Log non-fatal or warning messages.
        Verbose - Send all logs.
    .PARAMETER LogType
        How to send logs to the stream. Defaults to the $AugerContext default log type.

        Summary sends the contents of $AugerContext.LogFile at the end of the log session (must use Close-AugerSession).
        AdHoc sends logs as they're recieved by Auger through Write-Auger.
    .PARAMETER Disabled
        Switch. Creates the Log Stream in a disabled state.
    #>
    param (
        [ValidateScript({
            if ($_ -notmatch '^[(http|https)://].*$') {
                throw "Provided Slack webhook [$_] is not a properly formatted webhook."
            }
            return $true
        })]
        [string]$SlackWebhook,

        [ValidateSet('Quiet', 'Error', 'Warn', 'Verbose')]
        [string]
        $LogVerbosity = $AugerContext.DefaultVerbosity,

        [ValidateSet('Summary', 'AdHoc')]
        [string]
        $LogType = $AugerContext.DefaultLogType,

        [switch]
        $Disabled
    )

    $stream = [pscustomobject]@{
        Name        = 'Slack'
        Enabled     = (-not $Disabled)
        Webhook     = $SlackWebhook
        Verbosity   = $LogVerbosity
        LogType     = $LogType
        Command     = 'Send-SlackLog'
    }

    $AugerContext.LogStreams += $stream
}
