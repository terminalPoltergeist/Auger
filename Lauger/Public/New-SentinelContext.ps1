function New-SentinelContext {
    <#
    .SYNOPSIS
        Initialize a messaging and logging context.
    .DESCRIPTION
        This function initializes the module's namespace variables.
        The variable mapping can be found in the module's root .psm1 file. It is called $SentinelContext.
    .PARAMETER Application
        Name of the application the logging context is created for. Used to label logs sent to Splunk, Slack, etc.
    .PARAMETER SlackWebhook
        The http webhook endpoint for the Slack channel application.
    .PARAMETER SenderEmail
        Email address to send automated messages from. Usually a service account like hosting-support@umn.edu.
    .PARAMETER SMTPCreds
        NetworkCredentials for authenticating with the SMTP server for sending email messages.
    .PARAMETER SMTPPort
        The port through which to send smtp traffic. Defaults to 587.
    .PARAMETER SMTPSSL
        Bool. Whether or not to use SSL for smtp transmission. Defaults to $true.
    .PARAMETER SplunkURI
        The http webhook endpoint for the Splunk collector.
    .PARAMETER SplunkAuthKey
        A SecureString containing an authorization key in the format "Splunk <token>".
    .PARAMETER SplunkVerbosity
        Logging level for Splunk.

        Quiet - No logging.
        Error - Log fatal errors.
        Warn - Log errors or potential errors that can be handled automatically.
        Verbose - Send all logs to Splunk.
    .PARAMETER SplunkLogType
        How to send logs to Splunk.
        Summary constructs a single log sumarry and sends it at the end of the logging session (must use Close-SentinelSession).
        AdHoc sends logs as they're recieved by Sentinel through Write-SentinelLog.
    .PARAMETER SlackVerbosity
        Logging level for Slack.

        Quiet - No logging.
        Error - Log fatal errors.
        Warn - Log errors or potential errors that can be handled automatically.
        Verbose - Send all logs to Slack.
    .PARAMETER SlackLogType
        How to send logs to Slack.
        Summary constructs a single log sumarry and sends it at the end of the logging session (must use Close-SentinelSession).
        AdHoc sends logs as they're recieved by Sentinel through Write-SentinelLog.
    .PARAMETER EmailVerbosity
        Logging level for Email.

        Quiet - No logging.
        Error - Log fatal errors.
        Warn - Log errors or potential errors that can be handled automatically.
        Verbose - Send all logs to email.
    .PARAMETER EmailLogType
        How to send logs to email.
        Summary constructs a single log sumarry and sends it at the end of the logging session (must use Close-SentinelSession).
        AdHoc sends logs as they're recieved by Sentinel through Write-SentinelLog.
    .PARAMETER LogVerbosity
        Logging level to use for all output streams. Defaults to Error.
        Sets the default for all streams. Can be overridden by specifying a logging level for a given stream.
        ie. '-LogVerbosity Verbose -EmailVerbosity Error' will use verbose logging to all output streams except Email, which will use Error logging.

        Quiet - No logging.
        Error - Log fatal errors.
        Warn - Log errors or potential errors that can be handled automatically.
        Verbose - Send all logs.
    .PARAMETER LogType
        Default method for sending logs to all log streams. Defaults to Summary.
        Summary constructs a single log sumarry and sends it at the end of the logging session (must use Close-SentinelSession).
        AdHoc sends logs as they're recieved by Sentinel through Write-SentinelLog.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$Application,

        [ValidateScript({
            if ($_ -notmatch '^[(http|https)://].*$') {
                throw "Provided Slack webhook [$_] is not a properly formatted webhook."
            }
            return $true
        })]
        [string]$SlackWebhook,

        [ValidateSet('Quiet', 'Error', 'Warn', 'Verbose')]
        [string]$SlackVerbosity,

        [ValidateSet('Summary', 'AdHoc')]
        [string]$SlackLogType,

        [ValidateScript({
            if ($_ -notmatch '^[a-zA-Z0-9]+@.*$') {
                throw "Provided sender email [$_] is not a valid email."
            }
            return $true
        })]
        [string]$SenderEmail,

        [System.Net.NetworkCredential]$SMTPCreds,

        [int]$SMTPPort = 587,

        [bool]$SMTPSSL = $true,

        [ValidateSet('Quiet', 'Error', 'Warn', 'Verbose')]
        [string]$EmailVerbosity,

        [ValidateSet('Summary', 'AdHoc')]
        [string]$EmailLogType,

        [string]$SplunkURI,

        [securestring]$SplunkAuthKey,

        [ValidateSet('Quiet', 'Error', 'Warn', 'Verbose')]
        [string]$SplunkVerbosity,

        [ValidateSet('Summary', 'AdHoc')]
        [string]$SplunkLogType,

        [ValidateSet('Quiet', 'Error', 'Warn', 'Verbose')]
        [string]$LogVerbosity = 'Error',

        [ValidateSet('Summary', 'AdHoc')]
        [string]$LogType = 'Summary'
    )

    if ($Application) {
        $SentinelContext.Application = $Application
        Write-Verbose "SentinelContext for application [$Application]"
    }
    $SentinelContext.Host = if ($env:COMPUTERNAME) {$env:COMPUTERNAME} else {Hostname}
    Write-Verbose "SentinelContext for host [$SentinelContext.Host]"

    if ($LogVerbosity) {
        foreach ($stream in $SentinelContext.LogStreams.Keys) {$SentinelContext.LogStreams[$stream].Verbosity = $LogVerbosity}
        Write-Verbose "Setting SentinelContext default log verbosity [$LogVerbosity]"
    }

    if ($LogType) {
        foreach ($stream in $SentinelContext.LogStreams.Keys) {$SentinelContext.LogStreams[$stream].LogType = $LogType}
        Write-Verbose "Setting SentinelContext default log type [$LogType]"
    }

    $enableEmail = $true
    if ($SenderEmail) {$SentinelContext.LogStreams.Mail.Sender = $SenderEmail} else {$enableEmail = $false}
    if ($SMTPCreds) {$SentinelContext.LogStreams.Mail.SMTPCreds = $SMTPCreds} else {$enableEmail = $false}
    if ($enableEmail) {
        if ($SMTPPort) {$SentinelContext.LogStreams.Mail.SMTPPort = $SMTPPort}
        if ($SMTPSSL) {$SentinelContext.LogStreams.Mail.SMTPSSL = $SMTPSSL}
        $SentinelContext.LogStreams.Email.Enabled = $true
        Write-Verbose "Enabled Sentinel log stream [Email]"

        if ($EmailVerbosity) {
            $SentinelContext.LogStreams.Mail.Verbosity = $EmailVerbosity
            Write-Verbose "Setting Sentinel log stream [Email] verbosity [$EmailVerbosity]"
        }
        if ($EmailLogType) {
            $SentinelContext.LogStreams.Mail.LogType = $EmailLogType
            Write-Verbose "Setting Sentinel log stream [Email] log type [$EmailLogType]"
        }
    }

    $enableSlack = $true
    if ($SlackWebhook) {$SentinelContext.LogStreams.Slack.Webhook = $SlackWebhook} else {$enableSlack = $false}
    if ($enableSlack) {
        $SentinelContext.LogStreams.Slack.Enabled = $true
        Write-Verbose "Enabled Sentinel log stream [Slack]"

        if ($SlackVerbosity) {
            $SentinelContext.LogStreams.Slack.Verbosity = $SlackVerbosity
            Write-Verbose "Setting Sentinel log stream [Slack] verbosity [$SlackVerbosity]"
        }
        if ($SlackLogType) {
            $SentinelContext.LogStreams.Slack.LogType = $SlackLogType
            Write-Verbose "Setting Sentinel log stream [Slack] log type [$SlackLogType]"
        }
    }

    $enableSplunk = $true
    if ($SplunkURI) {$SentinelContext.LogStreams.Splunk.Uri = $SplunkURI} else {$enableSplunk = $false}
    if ($SplunkAuthKey) {
        $SentinelContext.LogStreams.Splunk.Headers['authorization'] = $([Net.NetworkCredential]::new('', $SplunkAuthKey).Password)
    } else {$enableSplunk = $false}
    if ($enableSplunk) {
        $SentinelContext.LogStreams.Splunk.Enabled = $true
        Write-Verbose "Enabled Sentinel log stream [Splunk]"

        if ($SplunkVerbosity) {
            $Sentinel.Splunk.Verbosity = $SplunkVerbosity
            Write-Verbose "Setting Sentinel log stream [Splunk] verbosity [$SplunkVerbosity]"
        }
        if ($SplunkLogType) {
            $SentinelContext.LogStreams.Splunk.LogType = $SplunkLogType
            Write-Verbose "Setting Sentinel log stream [Splunk] log type [$SplunkLogType]"
        }
    }
    return $SentinelContext
}
