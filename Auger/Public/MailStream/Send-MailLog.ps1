function Send-MailLog {
    <#
    .SYNOPSIS
        Send a log to an email over SMTP.
    .DESCRIPTION
        This function sends a log to a specified email account using SMTP.
        It creates a new MailMessage object and sets the sender, recipient, subject, and body of the email.
        It then creates an SmtpClient object, sets the SMTP server details, enables SSL, sets the credentials, and sends the email.
    .PARAMETER To
        The recipient email address. Defaults to the configured Receiver in the $AugerContext Mail LogStream.
    .PARAMETER Subject
        The email subject line. Defaults to "$Severity: $Application from $Source on $Host".
        $Application, $Source, and $Host variables are configured in $AugerContext.
    .PARAMETER Body
        The log body to send.
    .PARAMETER Severity
        Info, Warn, or Error.
        Labeling the log with a severity. Used to construct a message subject if one is not provided.
    .EXAMPLE
       Send-MailLog -To "recipient@example.com" -subject "Test Email" -body "This is a test email."
    .NOTES
       The function uses the SMTP server smtp.gmail.com on port 587 (or configured in the Mail LogStream in $AugerContext).
       The credentials for the SMTP server are configured in the Mail LogStream in $AugerContext.
    #>

    param (
        [Parameter (Mandatory = $true, Position = 0)]
        [string]
        $Body,

        [Parameter(ParameterSetName="Custom", Mandatory=$true)]
        [ValidateScript({
            if ($_ -notmatch '^[a-zA-Z0-9]+@.*$') {
                throw "Provided sender email [$_] is not a valid email."
            }
            return $true
        })]
        [string]
        $From,

        [Parameter(ParameterSetName="Custom", Mandatory=$true)]
        [Parameter(ParameterSetName="Stream")]
        [ValidateScript({
            if ($_ -notmatch '^[a-zA-Z0-9]+@.*$') {
                throw "Provided recipient email [$_] is not a valid email."
            }
            return $true
        })]
        [string]
        $To,

        [Parameter(ParameterSetName="Custom", Mandatory=$true)]
        [Parameter(ParameterSetName="Stream")]
        [string]
        $Subject,

        [Parameter(ParameterSetName="Custom")]
        [string]
        $SMTPPort = '587',

        [Parameter(ParameterSetName="Custom")]
        [bool]
        $SMTPSSL = $true,

        [Parameter(ParameterSetName="Custom", Mandatory=$true)]
        [System.Net.NetworkCredential]
        $SMTPCreds,

        [ValidateSet('Info', 'Warn', 'Error')]
        [string]
        $Severity = 'Info',

        [Parameter(ParameterSetName="Stream", ValueFromPipeline)]
        [pscustomobject]
        $Stream = ($AugerContext.LogStreams | Where-Object -Property Name -eq 'Mail')
    )

    if ($PSCmdlet.ParameterSetName -eq 'Custom') {
        $Stream = [pscustomobject]@{
        Name        = 'Mail'
        Enabled     = $true
        Sender      = $From
        Receiver    = $To
        SMTPPort    = $SMTPPort
        SMTPCreds   = $SMTPCreds
        SMTPSSL     = $SMTPSSL
        Verbosity   = $LogVerbosity
        LogType     = $LogType
        Command     = 'Send-MailLog'
    }
    }

    foreach ($each in $Stream) {
        if ((-not $To) -and (-not $Stream)) {
            throw "No destination email provided. Did you initialize a MailStream?"
        } elseif (-not $To) { $To = $Stream.Receiver }

        $mail = New-Object System.Net.Mail.MailMessage
        $mail.From = $each.Sender

        $mail.To.Add($To);
        if (-not $Subject -and $PSCmdlet.ParameterSetName -eq 'Stream') {
            $Subject = "$Severity`: $($AugerContext.Application) from $($AugerContext.Source) on $($AugerContext.Host)"
        }
        $mail.Subject = $Subject
        $mail.Body = $Body

        if ($PSCmdlet.ParameterSetName -eq 'Stream' -and $each.SMTPPort) {
            $smtp = new-object Net.Mail.SmtpClient("smtp.gmail.com", $each.SMTPPort)
        } else {
            $smtp = new-object Net.Mail.SmtpClient("smtp.gmail.com", $SMTPPort)
        }

        $smtp.EnableSSL = $each.SMTPSSL
        $smtp.Credentials = $each.SMTPCreds
        $smtp.send($mail)
    }
}
