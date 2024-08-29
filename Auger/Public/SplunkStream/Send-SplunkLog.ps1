function Send-SplunkLog {
    <#
    .Synopsis
        Send an event log to Splunk HTTP Event Collector
    .DESCRIPTION
        This function uses the Splunk HTTP Event Collector to send logs to Splunk.
    .PARAMETER Uri
        URI for HEC endpoint. Defaults to the URI value from the Splunk LogStream in $AugerContext.
    .PARAMETER SplunkAuthKey
        A SecureString containing the access key for the Splunk HEC.
    .PARAMETER Headers
        Key value pairs for optional HTTP headers. The Authorization headers is automatically configured from $SplunkAuthKey.
    .PARAMETER Host
        The hostname of the machine sending events. Defaults to the value from $AugerContext.Host.
    .PARAMETER Source
        The source application sending the data. Defaults to $AugerContext.Application.
    .PARAMETER SourceType
        The type of source sending the data. Will be prepended with 'HEC:'.
    .PARAMETER Retries
        How many retries will be attempted if invoking fails
    .PARAMETER SecondsDelay
        How many seconds to wait between retries
    .PARAMETER Metadata
        Part of Splunk Metadata for event. Combination of host,source,sourcetype in performatted hashtable, will be comverted to JSON
    .PARAMETER EventData
        Event Data in hastable or pscustomeobject, will be comverted to JSON
    .PARAMETER JsonDepth
        Optional, specifies the Depth parameter to pass to ConvertTo-JSON, defaults to 100
    .PARAMETER Severity
        Info, Warn, or Error.
        Labeling the log with a severity. Used to label the eventData body if message was given as a string.
    .EXAMPLE
        Send-SplunkEvent -SplunkAuthKey $secret -SourceType 'AzureRunbook' -EventData @{'JobID' = '123'; 'msg' = 'Init run'}
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # This can be [Management.Automation.PSCustomObject] or [Collections.Hashtable]
        [Parameter(Mandatory, Position=0)]
        $EventData,

        [string]$Uri = ($AugerContext.LogStreams | Where-Object -Property Name -eq 'Splunk').URI,

        [securestring]$SplunkAuthKey,

        [hashtable]$Headers = @{},

        [string]$Source = $AugerContext.Application,

        [String]$SourceType = $AugerContext.Source,

        [Alias("Host")]
        [String]$EventHost = $AugerContext.Host,

        [hashtable]$Metadata,

        [int]$Retries = 5,

        [int]$SecondsDelay = 10,

        [int]$JsonDepth = 100,

        [ValidateSet('Info', 'Warn', 'Error')]
        [string]$Severity = 'Info'
    )

    begin{
        $retryCount = 0
        $completed = $false
        $response = $null
    } process {
        if ((-not $Headers.Authorization)) {
            if ((-not $SplunkAuthKey)) {
                $Headers.Authorization = ($AugerContext.LogStreams | Where-Object -Property Name -eq 'Splunk').Headers.Authorization
            } else {
                $Headers.Authorization = $SplunkAuthKey
            }
        }

        if ($Headers.Authorization.Count -gt 1) {
            $Headers.Authorization = $Headers.Authorization[0]
            Write-Verbose "Send-SplunkLog multiple Authorization headers configured for [Splunk] selecting the first one."
        } elseif ($Headers.Authorization.Count -lt 1) {
            throw 'No Authorization header found. Did you initialize AugerContext? Or provide a $SplunkAuthKey'
        }

        # convert the securestring key for sending to Splunk
        $Headers.Authorization = $([Net.NetworkCredential]::new('', $Headers.Authorization).Password)

        if ($metadata){$bodySplunk = $metadata.Clone()}
        else {$bodySplunk = @{'host' = $EventHost;'source' = $source;'sourcetype' = "HEC:$sourcetype"}}

        $bodySplunk['time'] = (Get-Date).toUniversalTime() | Get-Date -UFormat %s

        # if string, convert to hashtable
        if ($EventData.GetType().Name -eq 'String') {
            $EventData = @{"$Severity" = $EventData}
        }
        $internalEventData = $eventData | ConvertTo-Json | ConvertFrom-Json
        Add-Member -InputObject $internalEventData -Name "SplunkHECRetry" -Value $retryCount -MemberType NoteProperty
        Add-Member -InputObject $internalEventData -Name "guid" -Value $AugerContext.GUID -MemberType NoteProperty
        $bodySplunk['event'] = $internalEventData

        $shouldProcessMessage = "Sending the following data to Splunk collector {0}:`n{1}" -f ($AugerContext.LogStreams | Where-Object -Property Name -eq 'Splunk').URI, ($bodySplunk | ConvertTo-Json)
        if ($PSCmdlet.ShouldProcess($shouldProcessMessage, ($bodySplunk | ConvertTo-Json), "Send log to Splunk")) {
            while (-not $completed) {
                try {
                    $response = Invoke-RestMethod -Uri $uri -Headers $Headers -UseBasicParsing -Body ($bodySplunk | ConvertTo-Json -Depth $JsonDepth) -Method Post
                    if ($response.text -ne 'Success' -or $response.code -ne 0){throw "Failed to submit to Splunk HEC $($response)"}
                    $completed = $true
                } catch {
                    if ($retrycount -ge $Retries) {
                        throw
                    } else {
                        Start-Sleep $SecondsDelay
                        $retrycount++
                        $bodySplunk.event.SplunkHECRetry = $retryCount
                    }
                }
            }
        }
    }
}
