function New-MailStream {
    <#
    .SYNOPSIS
        Initialize a Mail Stream.
    .DESCRIPTION
        This function initializes a Mail Stream.
        New Mail Streams are appended to the module's AugerContext LogStreams array.
    .PARAMETER SenderEmail
        Email address to send automated messages from. Usually a service account like no-reply@company.com.
    .PARAMETER ReceiverEmail
        Email address to send automated messages to.
    .PARAMETER SMTPCreds
        NetworkCredentials for authenticating with the SMTP server for sending email messages.
    .PARAMETER SMTPPort
        The port through which to send smtp traffic. Defaults to 587.
    .PARAMETER SMTPSSL
        Bool. Whether or not to use SSL for smtp transmission. Defaults to $true.
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
        Switch. Creates the Mail Log Stream in a disabled state.
    #>
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            if ($_ -notmatch '^[a-zA-Z0-9\-]+@.*$') {
                throw "Provided sender email [$_] is not a valid email."
            }
            return $true
        })]
        [string]
        $SenderEmail,

        [Parameter(Mandatory=$true)]
        [ValidateScript({
            if ($_ -notmatch '^[a-zA-Z0-9\-]+@.*$') {
                throw "Provided receiver email [$_] is not a valid email."
            }
            return $true
        })]
        [string]
        $ReceiverEmail,

        [System.Net.NetworkCredential]
        $SMTPCreds,

        [int]
        $SMTPPort = 587,

        [bool]
        $SMTPSSL = $true,

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
        Name        = 'Mail'
        Enabled     = (-not $Disabled)
        Sender      = $SenderEmail
        Receiver    = $ReceiverEmail
        SMTPPort    = $SMTPPort
        SMTPCreds   = $SMTPCreds
        SMTPSSL     = $SMTPSSL
        Verbosity   = $LogVerbosity
        LogType     = $LogType
        Command     = 'Send-MailLog'
    }

    $AugerContext.LogStreams += $stream
}
