Function Send-MailMessage {
    <#
    .SYNOPSIS
       This function sends an email using SMTP.

    .DESCRIPTION
       The Send-Mail function sends an email using the SMTP protocol. It creates a new MailMessage object and sets the sender, recipient, subject, and body of the email. It then creates an SmtpClient object, sets the SMTP server details, enables SSL, sets the credentials, and sends the email.

    .PARAMETER to
       The recipient's email address. This is a mandatory parameter.

    .PARAMETER from
        The email address to send the email from. This is an optional parameter. Throws error if not supplied and $Mail.Sender is null.

    .PARAMETER subject
       The subject of the email. This is a mandatory parameter.

    .PARAMETER body
       The body of the email. This is a mandatory parameter.

    .EXAMPLE
       Send-Mail -to "recipient@example.com" -from "me@example.com" -subject "Test Email" -body "This is a test email."

    .NOTES
       The function uses the SMTP server smtp.gmail.com on port 587 (or configured in $Mail.SMTPPort). The credentials for the SMTP server are configured in $Mail.SMTPCreds.
    #>

    param (
        [Parameter (Mandatory = $true)]
        [string]$to,
        [Parameter (Mandatory = $false)]
        [string]$from,
        [Parameter (Mandatory = $true)]
        [string]$subject,
        [Parameter (Mandatory = $true)]
        [string]$body
    )

    $message = new-object Net.Mail.MailMessage;

    if (!$Mail.Sender -and !$from) {
        throw "No sender email provided."
    }
    if ($from) {
        $message.From = $from;
    } else {
        $message.From = $Mail.Sender
    }

    $message.To.Add($to);
    $message.Subject = $subject;
    $message.Body = $body;

    if ($Mail.SMTPPort) {
        $smtp = new-object Net.Mail.SmtpClient("smtp.gmail.com", $Mail.SMTPPort);
    } else {
        $smtp = new-object Net.Mail.SmtpClient("smtp.gmail.com", "587");
    }

    $smtp.EnableSSL = $Mail.SMTPSSL;
    $smtp.Credentials = $Mail.SMTPCreds;
    # $smtp.send($message);
    Write-Host $smtp.EnableSsl
}
