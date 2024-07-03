function Clear-AugerContext {
    [CmdletBinding()]
    param ()

    $Script:AugerContext = [pscustomobject]@{
        Application     = $null
        Host            = $null
        Source          = $null
        LogFile         = $null

        LogStreams = @(
            [pscustomobject]@{
                Name        = 'Email'
                Enabled     = $false
                Sender      = $null
                SMTPPort    = $null
                SMTPCreds   = New-Object System.Net.NetworkCredential($null, $null)
                SMTPSSL     = $true
                Verbosity   = $null
                LogType     = $null
            }
            [pscustomobject]@{
                Name        = 'Slack'
                Enabled     = $false
                Webhook     = $null
                Verbosity   = $null
                LogType     = $null
            }
            [pscustomobject]@{
                Name        = 'Splunk'
                Enabled     = $false
                Uri         = $null
                Headers     = $null
                Verbosity   = $null
                LogType     = $null
            }
        )
    }
}
