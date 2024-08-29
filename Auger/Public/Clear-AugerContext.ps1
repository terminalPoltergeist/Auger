function Clear-AugerContext {
    [CmdletBinding()]
    param ()

    if ($Script:AugerContext.LogFile.FullName -and (Test-Path $Script:AugerContext.LogFile.FullName)) {
        Remove-Item $Script:AugerContext.LogFile.FullName
    }

    $Script:AugerContext = [pscustomobject]@{
        Application     = $null
        Host            = $null
        Source          = $null
        LogFile         = $null
        GUID            = $null

        LogStreams = @(
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
