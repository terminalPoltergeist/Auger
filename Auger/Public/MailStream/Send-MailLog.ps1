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
        [string]$Body,

        [ValidateScript({
            if ($_ -notmatch '^[a-zA-Z0-9]+@.*$') {
                throw "Provided sender email [$_] is not a valid email."
            }
            return $true
        })]
        [string]$To = (($AugerContext.LogStreams | Where-Object -Property Name -eq 'Mail').Receiver),

        [string]$Subject,

        [ValidateSet('Info', 'Warn', 'Error')]
        [string]$Severity = 'Info'
    )

    if (-not $To) {
        throw "No destination email provided."
    }

    $mail = New-Object System.Net.Mail.MailMessage
    $mail.From = ($AugerContext.LogStreams | Where-Object -Property Name -eq 'Mail').Sender

    $mail.To.Add($to);
    if (-not $Subject) {
        $Subject = "$Severity`: $($AugerContext.Application) from $($AugerContext.Source) on $($AugerContext.Host)"
    }
    $mail.Subject = $Subject
    $mail.Body = $Body

    if (($AugerContext.LogStreams | Where-Object -Property Name -eq 'Mail').SMTPPort) {
        $smtp = new-object Net.Mail.SmtpClient("smtp.gmail.com", ($AugerContext.LogStreams | Where-Object -Property Name -eq 'Mail').SMTPPort)
    } else {
        $smtp = new-object Net.Mail.SmtpClient("smtp.gmail.com", "587")
    }

    $smtp.EnableSSL = ($AugerContext.LogStreams | Where-Object -Property Name -eq 'Mail').SMTPSSL
    $smtp.Credentials = ($AugerContext.LogStreams | Where-Object -Property Name -eq 'Mail').SMTPCreds
    $smtp.send($mail)
}
