Function Send-SlackLog {
    <#
    .SYNOPSIS
       This function sends an alert to a Slack channel via webhook.
    .DESCRIPTION
        The Send-SlackLog function sends a body of text to a Slack webhook that posts the content as a message in a Slack channel.
    .PARAMETER Body
        The body of the alert/log to send to Slack.
    .EXAMPLE
        Send-SlackLog -Body "This is an message."
    #>
    param (
        [Parameter (Mandatory = $true, Position = 0)]
        [string]$Body
    )

    $headers = @{
        'Content-Type' = 'application/json'
        'Transfer-Encoding' = 'chunked'
    }
    $SlackBody = "{ 'Body': '$body' }"

    $uri = ($AugerContext.LogStreams | Where-Object -Property Name -eq 'Slack').Webhook
    if (-not $uri) {
        throw 'No webhook configured for Slack. Did you initialize $AugerContext?'
    }

    $null = Invoke-RestMethod -uri $uri -Method Post -body $SlackBody -Headers $headers
}
