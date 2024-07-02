BeforeAll {
    Import-Module ./Lauger/
}

Describe 'New-LaugerContext' {
    BeforeEach {
        Clear-LaugerContext
    }

    It 'Initializes a default context' {
        New-LaugerContext -Application 'Pester'
        $ctx = Get-LaugerContext
        $ctx.Application | Should -Be 'Pester'
        $defaultLogStreams = @{
            Mail = [ordered]@{
                Enabled     = $false
                Sender      = $null
                SMTPPort    = $null
                SMTPCreds   = New-Object System.Net.NetworkCredential($null, $null)
                SMTPSSL     = $true
                Verbosity   = 'Error'
                LogType     = 'Summary'
            }
            Slack = [ordered]@{
                Enabled     = $false
                Webhook     = $null
                Verbosity   = 'Error'
                LogType     = 'Summary'
            }
            Splunk = [ordered]@{
                Enabled     = $false
                Uri         = $null
                Headers     = $null
                Verbosity   = 'Error'
                LogType     = 'Summary'
            }
        }
        ($ctx.LogStreams | ConvertTo-Json -Depth 100) | Should -Be ($defaultLogStreams | ConvertTo-Json -Depth 100)
    }

    It 'Initializes single log stream' {
        $params = @{
            Application = 'Pester'
            SlackWebhook = 'https://test.slack.nothing123'
            SlackVerbosity = 'Verbose'
            SlackLogType = 'AdHoc'
        }
        New-LaugerContext @params
        $ctx = Get-LaugerContext
        $ctx.Application | Should -Be 'Pester'
        $LogStreams = @{
            Mail = [ordered]@{
                Enabled     = $false
                Sender      = $null
                SMTPPort    = $null
                SMTPCreds   = New-Object System.Net.NetworkCredential($null, $null)
                SMTPSSL     = $true
                Verbosity   = 'Error'
                LogType     = 'Summary'
            }
            Slack = [ordered]@{
                Enabled     = $true
                Webhook     = $params.SlackWebhook
                Verbosity   = $params.SlackVerbosity
                LogType     = $params.SlackLogType
            }
            Splunk = [ordered]@{
                Enabled     = $false
                Uri         = $null
                Headers     = $null
                Verbosity   = 'Error'
                LogType     = 'Summary'
            }
        }
        ($ctx.LogStreams | ConvertTo-Json -Depth 100) | Should -Be ($LogStreams | ConvertTo-Json -Depth 100)
    }
    It 'Initializes all log streams' {
        $params = @{
            Application = 'Pester'
            SlackWebhook = 'https://test.slack.nothing123'
            SlackVerbosity = 'Verbose'
            SlackLogType = 'AdHoc'
            SenderEmail = 'noone@test.com'
            SMTPCreds = New-Object System.Net.NetworkCredential('user', 'password')
            SplunkURI = 'https://test.splunk.webhook123'
            SplunkAuthKey = ConvertTo-SecureString 'Splunk supersecret' -AsPlainText
        }
        New-LaugerContext @params
        $ctx = Get-LaugerContext
        $ctx.Application | Should -Be 'Pester'
        $LogStreams = @{
            Mail = [ordered]@{
                Enabled     = $true
                Sender      = $params.SenderEmail
                SMTPPort    = 587
                SMTPCreds   = $params.SMTPCreds
                SMTPSSL     = $true
                Verbosity   = 'Error'
                LogType     = 'Summary'
            }
            Slack = [ordered]@{
                Enabled     = $true
                Webhook     = $params.SlackWebhook
                Verbosity   = $params.SlackVerbosity
                LogType     = $params.SlackLogType
            }
            Splunk = [ordered]@{
                Enabled     = $true
                Uri         = $params.SplunkURI
                Headers     = @{Authorization = (ConvertTo-SecureString "Splunk supersecret" -AsPlainText)}
                Verbosity   = 'Error'
                LogType     = 'Summary'
            }
        }
        ($ctx.LogStreams | ConvertTo-Json -Depth 100) | Should -Be ($LogStreams | ConvertTo-Json -Depth 100)
    }

}
