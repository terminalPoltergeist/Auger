function Clear-LaugerContext {
    [CmdletBinding()]
    param ()

    $Script:LaugerContext = [pscustomobject]@{
        Application     = $null
        Host            = $null
        Source          = $null

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
                Summary     = $null
            }
            [pscustomobject]@{
                Name        = 'Slack'
                Enabled     = $false
                Webhook     = $null
                Verbosity   = $null
                LogType     = $null
                Summary     = $null
            }
            [pscustomobject]@{
                Name        = 'Splunk'
                Enabled     = $false
                Uri         = $null
                Headers     = $null
                Verbosity   = $null
                LogType     = $null
                Summary     = $null
            }
        )
    }
}
