Function Send-SlackMessage {
    <#
    .SYNOPSIS
       This function sends an alert to a Slack channel via webhook.

    .DESCRIPTION
        The Send-SlackAlert function sends a body of text to a Slack webhook that posts the content as a message in a Slack channel.

    .PARAMETER body
        The body of the alert/log to send to Slack.

    .EXAMPLE
        Send-SlackAlert -body "This is an alert"
    #>
    param (
        [Parameter (Mandatory = $true)]
        [string]$body
    )

    $ContentType= 'application/json'
    $SlackBody = @"
    {
        "Body": "$body",
    }
"@

Invoke-RestMethod -uri $Slack.Webhook -Method Post -body $SlackBody -ContentType $ContentType
}

Function Set-SlackWebhook {
    param (
        [Parameter (Mandatory = $true)]
        [string]$webhook
    )

    $Slack.Webhook = $webhook
}
