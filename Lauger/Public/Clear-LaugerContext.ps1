function Clear-LaugerContext {
    [CmdletBinding()]
    param ()

    $Script:LaugerContext = [ordered]@{
        Application     = $null
        Host            = $null

        LogStreams = @{
            Mail = [ordered]@{
                Enabled     = $false
                Sender      = $null
                SMTPPort    = $null
                SMTPCreds   = New-Object System.Net.NetworkCredential($null, $null)
                SMTPSSL     = $true
                Verbosity   = $null
                LogType     = $null
            }
            Slack = [ordered]@{
                Enabled     = $false
                Webhook     = $null
                Verbosity   = $null
                LogType     = $null
            }
            Splunk = [ordered]@{
                Enabled     = $false
                Uri         = $null
                Headers     = $null
                Verbosity   = $null
                LogType     = $null
            }
        }
    }
}
