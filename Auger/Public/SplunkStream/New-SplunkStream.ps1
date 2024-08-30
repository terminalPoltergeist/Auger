function New-SplunkStream {
    <#
    .SYNOPSIS
        Initialize a Splunk Stream.
    .DESCRIPTION
        This function initializes a Splunk Stream.
        New Splunk Streams are appended to the module's AugerContext LogStreams array.
     .PARAMETER SplunkURI
        The http webhook endpoint for the Splunk collector.
    .PARAMETER SplunkAuthKey
        A SecureString containing an authorization key in the format "Splunk <token>".
        Will be stored as a SecureString in $AugerContext.LogStreams.Splunk.Headers.Authorization.
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
        Switch. Creates the Splunk Log Stream in a disabled state.
    #>
    param (
        [string]
        $SplunkURI,

        [securestring]
        $SplunkAuthKey,

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
        Name        = 'Splunk'
        Enabled     = (-not $Disabled)
        Uri         = $SplunkURI
        Headers     = @{Authorization = $SplunkAuthKey}
        Verbosity   = $LogVerbosity
        LogType     = $LogType
        Command     = 'Send-SplunkLog'
    }

    $AugerContext.LogStreams += $stream
}
