function New-AugerContext {
    <#
    .SYNOPSIS
        Initialize a Auger context.
    .DESCRIPTION
        This function initializes the module's namespace variables.
        The variable mapping can be found in the module's root .psm1 file. It is called $AugerContext.
    .PARAMETER Application
        Name of the application the logging context is created for. Used to label logs sent to Splunk, Slack, etc.
    .PARAMETER Source
        Source of the logs. Used as metadata in some log streams.
        Can describe platform/infrastructure. ex. AzureRunbook, AzureFunction, Ansible, etc.
        Defaults to Auger.
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
        Will be stored as a SecureString in $AugerContext.LogStreams.Splunk.Headers.Authorization.
    .PARAMETER SplunkVerbosity
        Logging level for Splunk.

        Quiet - No logging.
        Error - Log fatal errors.
        Warn - Log errors or potential errors that can be handled automatically.
        Verbose - Send all logs to Splunk.
    .PARAMETER SplunkLogType
        How to send logs to Splunk.
        Summary sends the contents of $AugerContext.LogFile at the end of the log session (must use Close-AugerSession).
        AdHoc sends logs as they're recieved by Auger through Write-AugerLog.
    .PARAMETER SlackVerbosity
        Logging level for Slack.

        Quiet - No logging.
        Error - Log fatal errors.
        Warn - Log errors or potential errors that can be handled automatically.
        Verbose - Send all logs to Slack.
    .PARAMETER SlackLogType
        How to send logs to Slack.
        Summary sends the contents of $AugerContext.LogFile at the end of the log session (must use Close-AugerSession).
        AdHoc sends logs as they're recieved by Auger through Write-AugerLog.
    .PARAMETER EmailVerbosity
        Logging level for Email.

        Quiet - No logging.
        Error - Log fatal errors.
        Warn - Log errors or potential errors that can be handled automatically.
        Verbose - Send all logs to email.
    .PARAMETER EmailLogType
        How to send logs to email.
        Summary sends the contents of $AugerContext.LogFile at the end of the log session (must use Close-AugerSession).
        AdHoc sends logs as they're recieved by Auger through Write-AugerLog.
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
        Summary sends the contents of $AugerContext.LogFile at the end of the log session (must use Close-AugerSession).
        AdHoc sends logs as they're recieved by Auger through Write-Auger.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$Application,

        [string]$Source = 'Auger',

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
        $AugerContext.Application = $Application
        Write-Verbose "Auger application [$Application]"
    }
    $AugerContext.Host = if ($env:COMPUTERNAME) {$env:COMPUTERNAME} else {Hostname}
    Write-Verbose "Auger host [$($AugerContext.Host)]"
    $AugerContext.Source = $Source
    Write-Verbose "Auger Source [$Source]"

    $AugerContext.LogFile = New-TemporaryFile
    Write-Verbose "Created log file at $($AugerContext.LogFile.FullName)"

    if ($LogVerbosity) {
        foreach ($stream in $AugerContext.LogStreams) {$stream.Verbosity = $LogVerbosity }
        Write-Verbose "Setting Auger default log verbosity [$LogVerbosity]"
    }

    if ($LogType) {
        foreach ($stream in $AugerContext.LogStreams) {
            $stream.LogType = $LogType
        }
        Write-Verbose "Setting Auger default log type [$LogType]"
    }

    $enableEmail = $true
    if ($SenderEmail) { ($AugerContext.LogStreams | Where-Object -Property Name -eq 'Email').Sender = $SenderEmail } else { $enableEmail = $false }
    if ($SMTPCreds) { ($AugerContext.LogStreams | Where-Object -Property Name -eq 'Email').SMTPCreds = $SMTPCreds } else { $enableEmail = $false }
    if ($enableEmail) {
        if ($SMTPPort) { ($AugerContext.LogStreams | Where-Object -Property Name -eq 'Email').SMTPPort = $SMTPPort }
        if ($SMTPSSL) { ($AugerContext.LogStreams | Where-Object -Property Name -eq 'Email').SMTPSSL = $SMTPSSL }
        ($AugerContext.LogStreams | Where-Object -Property Name -eq 'Email').Enabled = $true
        Write-Verbose "Enabled Auger log stream [Email]"

        if ($EmailVerbosity) {
            ($AugerContext.LogStreams | Where-Object -Property Name -eq 'Email').Verbosity = $EmailVerbosity
            Write-Verbose "Setting Auger log stream [Email] verbosity [$EmailVerbosity]"
        }
        if ($EmailLogType) {
            ($AugerContext.LogStreams | Where-Object -Property Name -eq 'Email').LogType = $EmailLogType
            Write-Verbose "Setting Auger log stream [Email] log type [$EmailLogType]"
        }
    }

    $enableSlack = $true
    if ($SlackWebhook) { ($AugerContext.LogStreams | Where-Object -Property Name -eq 'Slack').Webhook = $SlackWebhook } else { $enableSlack = $false }
    if ($enableSlack) {
        ($AugerContext.LogStreams | Where-Object -Property Name -eq 'Slack').Enabled = $true
        Write-Verbose "Enabled Auger log stream [Slack]"

        if ($SlackVerbosity) {
            ($AugerContext.LogStreams | Where-Object -Property Name -eq 'Slack').Verbosity = $SlackVerbosity
            Write-Verbose "Setting Auger log stream [Slack] verbosity [$SlackVerbosity]"
        }
        if ($SlackLogType) {
            ($AugerContext.LogStreams | Where-Object -Property Name -eq 'Slack').LogType = $SlackLogType
            Write-Verbose "Setting Auger log stream [Slack] log type [$SlackLogType]"
        }
    }

    $enableSplunk = $true
    if ($SplunkURI) { ($AugerContext.LogStreams | Where-Object -Property Name -eq 'Splunk').Uri = $SplunkURI } else { $enableSplunk = $false }
    if ($SplunkAuthKey) {
        ($AugerContext.LogStreams | Where-Object -Property Name -eq 'Splunk').Headers = @{Authorization = $SplunkAuthKey}
    } else {$enableSplunk = $false}
    if ($enableSplunk) {
        ($AugerContext.LogStreams | Where-Object -Property Name -eq 'Splunk').Enabled = $true
        Write-Verbose "Enabled Auger log stream [Splunk]"

        if ($SplunkVerbosity) {
            ($AugerContext.LogStreams | Where-Object -Property Name -eq 'Splunk').Verbosity = $SplunkVerbosity
            Write-Verbose "Setting Auger log stream [Splunk] verbosity [$SplunkVerbosity]"
        }
        if ($SplunkLogType) {
            ($AugerContext.LogStreams | Where-Object -Property Name -eq 'Splunk').LogType = $SplunkLogType
            Write-Verbose "Setting Auger log stream [Splunk] log type [$SplunkLogType]"
        }
    }
}
