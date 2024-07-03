BeforeAll {
    Import-Module ./Auger/
}

Describe 'New-AugerContext' {
    BeforeEach {
        Clear-AugerContext
    }

    It 'Initializes a default context' {
        New-AugerContext -Application 'Pester'
        $ctx = Get-AugerContext
        $ctx.Application | Should -Be 'Pester'
        $ctx.LogFile | Should -Match "[0-9a-zA-Z]+\.[tmp]"

        ($ctx.LogStreams | Where-Object -Property Name -eq 'Slack').Enabled | Should -Be $false
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Slack').Webhook | Should -Be $null
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Slack').Verbosity | Should -Be 'Error'
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Slack').LogType | Should -Be 'Summary'

        ($ctx.LogStreams | Where-Object -Property Name -eq 'Email').Enabled | Should -Be $false
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Email').Sender | Should -Be $null
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Email').SMTPPort | Should -Be $null
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Email').SMTPSSL | Should -Be $true
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Email').Verbosity | Should -Be 'Error'
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Email').LogType | Should -Be 'Summary'

        ($ctx.LogStreams | Where-Object -Property Name -eq 'Splunk').Enabled | Should -Be $false
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Splunk').Uri | Should -Be $null
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Splunk').Headers | Should -Be $null
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Splunk').Verbosity | Should -Be 'Error'
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Splunk').LogType | Should -Be 'Summary'
    }

    It 'Initializes single log stream' {
        $params = @{
            Application = 'Pester'
            SlackWebhook = 'https://test.slack.nothing123'
            SlackVerbosity = 'Verbose'
            SlackLogType = 'AdHoc'
        }
        New-AugerContext @params
        $ctx = Get-AugerContext
        $ctx.Application | Should -Be 'Pester'
        $ctx.LogFile | Should -Match "[0-9a-zA-Z]+\.[tmp]"

        ($ctx.LogStreams | Where-Object -Property Name -eq 'Slack').Enabled | Should -Be $true
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Slack').Webhook | Should -Be $params.SlackWebhook
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Slack').Verbosity | Should -Be $params.SlackVerbosity
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Slack').LogType | Should -Be $params.SlackLogType

        ($ctx.LogStreams | Where-Object -Property Name -eq 'Email').Enabled | Should -Be $false
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Email').Sender | Should -Be $null
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Email').SMTPPort | Should -Be $null
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Email').SMTPSSL | Should -Be $true
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Email').Verbosity | Should -Be 'Error'
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Email').LogType | Should -Be 'Summary'

        ($ctx.LogStreams | Where-Object -Property Name -eq 'Splunk').Enabled | Should -Be $false
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Splunk').Uri | Should -Be $null
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Splunk').Headers | Should -Be $null
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Splunk').Verbosity | Should -Be 'Error'
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Splunk').LogType | Should -Be 'Summary'
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
        New-AugerContext @params
        $ctx = Get-AugerContext
        $ctx.Application | Should -Be 'Pester'
        $ctx.LogFile | Should -Match "[0-9a-zA-Z]+\.[tmp]"

        ($ctx.LogStreams | Where-Object -Property Name -eq 'Slack').Enabled | Should -Be $true
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Slack').Webhook | Should -Be $params.SlackWebhook
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Slack').Verbosity | Should -Be $params.SlackVerbosity
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Slack').LogType | Should -Be $params.SlackLogType

        ($ctx.LogStreams | Where-Object -Property Name -eq 'Email').Enabled | Should -Be $true
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Email').Sender | Should -Be $params.SenderEmail
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Email').SMTPPort | Should -Be 587
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Email').SMTPCreds | Should -Be $params.SMTPCreds
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Email').SMTPSSL | Should -Be $true
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Email').Verbosity | Should -Be 'Error'
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Email').LogType | Should -Be 'Summary'

        ($ctx.LogStreams | Where-Object -Property Name -eq 'Splunk').Enabled | Should -Be $true
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Splunk').Uri | Should -Be $params.SplunkURI
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Splunk').Headers.Authorization | Should -Be $params.SplunkAuthKey
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Splunk').Verbosity | Should -Be 'Error'
        ($ctx.LogStreams | Where-Object -Property Name -eq 'Splunk').LogType | Should -Be 'Summary'
    }
}
