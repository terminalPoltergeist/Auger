function Send-SlackLog {
    <#
    .SYNOPSIS
       This function sends an alert to a Slack channel via webhook.
    .DESCRIPTION
        The Send-SlackLog function sends a body of text to a Slack webhook that posts the content as a message in a Slack channel.
    .PARAMETER Body
        The body of the alert/log to send to Slack.
    .PARAMETER Stream
        A Slack Stream pscustomobject to send the log to. If not provided will send to all enabled Slack Streams.
        TODO: there's gotta be a better way to target these??
    .EXAMPLE
        Send-SlackLog -Body "This is an message."
    #>
    [CmdletBinding()]
    param (
        [Parameter (Mandatory=$true, Position=0)]
        [string]
        $Body,

        [Parameter (ParameterSetName='Custom', Mandatory=$true)]
        [string]
        $Webhook,

        [Parameter(ParameterSetName='Stream', ValueFromPipeline=$true)]
        [pscustomobject]
        $Stream = ($AugerContext.LogStreams | Where-Object -Property Name -eq 'Slack')
    )

    $headers = @{
        'Content-Type' = 'application/json'
        'Transfer-Encoding' = 'chunked'
    }
    $SlackBody = "{ 'Body': '$Body' }"

    if ($PSCmdlet.ParameterSetName -eq 'Custom') {
        $Stream = [pscustomobject]@{
            Name        = 'Slack'
            Enabled     = $true
            Webhook     = $Webhook
        }
    }

    foreach ($each in $Stream) {
        if (-not $each.Webhook) {
            throw 'No webhook configured for Slack. Did you initialize a SlackStream?'
        }

        $null = Invoke-RestMethod -uri $each.Webhook -Method Post -body $SlackBody -Headers $headers
    }
}
