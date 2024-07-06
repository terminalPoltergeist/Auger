function Clear-AugerContext {
    [CmdletBinding()]
    param ()

    Remove-Item $Script:AugerContext.LogFile.FullName

    $Script:AugerContext = [pscustomobject]@{
        Application     = $null
        Host            = $null
        Source          = $null
        LogFile         = $null
        GUID            = $null

        LogStreams = @(
            [pscustomobject]@{
                Name        = 'Email'
                Enabled     = $false
                Sender      = $null
                Receiver    = $null
                SMTPPort    = $null
                SMTPCreds   = New-Object System.Net.NetworkCredential($null, $null)
                SMTPSSL     = $true
                Verbosity   = $null
                LogType     = $null
                Command     = 'Send-MailLog'
            }
            [pscustomobject]@{
                Name        = 'Slack'
                Enabled     = $false
                Webhook     = $null
                Verbosity   = $null
                LogType     = $null
                Command     = 'Send-SlackLog'
            }
            [pscustomobject]@{
                Name        = 'Splunk'
                Enabled     = $false
                Uri         = $null
                Headers     = $null
                Verbosity   = $null
                LogType     = $null
                Command     = 'Send-SplunkLog'
            }
        )
    }
}
