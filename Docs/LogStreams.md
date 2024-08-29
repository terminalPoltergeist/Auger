# Log Streams

When you write logs to Auger it will pass them through to one of the standard output streams.
Normal logs will write to the Information stdout stream.
Warning logs will write to the Warning stdout stream. Set with the `-IsWarning` flag.
Error logs will write to the Error stdout stream. Set with the `-IsError` flag.

There are also remote log streams that Auger can forward logs to.

The current available log streams are:

- Slack channel webhooks
- Splunk HTTP Event Collector
- SMTP email client

## Slack log stream

This is the null state of the Slack log stream.
```powershell
@{
    Name        = 'Slack'
    Enabled     = $false
    Webhook     = $null
    Verbosity   = $null
    LogType     = $null
    Command     = 'Send-SlackLog'
}
```

These fields can be configured with the following parameters on `New-AugerContext`

`-SlackWebhook`
