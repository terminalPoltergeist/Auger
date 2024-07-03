function Send-SplunkLog {
    <#
    .Synopsis
        Send an event log to Splunk HTTP Event Collector
    .DESCRIPTION
        This function uses the Splunk HTTP Event Collector to send logs to Splunk.
    .PARAMETER Uri
        URI for HEC endpoint. Defaults to the value from $MaLContext.Splunk.Uri.
    .PARAMETER SpunkAuthKey
        A SecureString containing the access key for the Splunk HEC.
    .PARAMETER Headers
        Key value pairs for optional HTTP headers. The Authorization headers is automatically configured from $SplunkAuthKey.
    .PARAMETER Host
        The hostname of the machine sending events. Defaults to the value from $MaLContext.Host.
    .PARAMETER Source
        The source application sending the data. Defaults to $MaLContext.Application.
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
    .EXAMPLE
        Send-SplunkEvent -SplunkAuthKey $secret -SourceType 'AzureRunbook' -EventData @{'JobID' = '123'; 'msg' = 'Init run'}
    #>
    [CmdletBinding()]
    param (
        [string]$Uri = $MaLContext.Splunk.Uri,

        [Parameter(Mandatory)]
        [securestring]$SpunkAuthKey,

        [Collections.Hashtable]$Headers,

        [string]$Source = $MaLContext.Application,

        [Parameter(Mandatory)]
        [String]$SourceType,

        [Alias("Host")]
        [String]$EventHost = $MaLContext.Host,

        [Collections.Hashtable]$Metadata,

        # This can be [Management.Automation.PSCustomObject] or [Collections.Hashtable]
        [Parameter(Mandatory)]
        $EventData,

        [int]$Retries = 5,

        [int]$SecondsDelay = 10,

        [int]$JsonDepth = 100
    )

    begin{
        $retryCount = 0
        $completed = $false
        $response = $null
    } process {
        $Headers = @{'Authorization' = ([Net.NetworkCredential]::new('', $SplunkAuthKey).Password)}

        if ($metadata){$bodySplunk = $metadata.Clone()}
        else {$bodySplunk = @{'host' = $EventHost;'source' = $source;'sourcetype' = "HEC:$sourcetype"}}

        #Splunk takes time in Unix Epoch format, so first get the current date,
        #convert it to UTC (what Epoch is based on) then format it to seconds since January 1 1970.
        #Without converting it to UTC the date would be offset by a number of hours equal to your timezone's offset from UTC
        $bodySplunk['time'] = (Get-Date).toUniversalTime() | Get-Date -UFormat %s

        $internalEventData = $eventData | ConvertTo-Json | ConvertFrom-Json
        Add-Member -InputObject $internalEventData -Name "SplunkHECRetry" -Value $retryCount -MemberType NoteProperty
        $bodySplunk['event'] = $internalEventData

        while (-not $completed) {
            try {
                $response = Invoke-RestMethod -Uri $uri -Headers $header -UseBasicParsing -Body ($bodySplunk | ConvertTo-Json -Depth $JsonDepth) -Method Post
                if ($response.text -ne 'Success' -or $response.code -ne 0){throw "Failed to submit to Splunk HEC $($response)"}
                $completed = $true
            }
            catch {
                if ($retrycount -ge $Retries) {
                    throw
                }
                else {
                    Start-Sleep $SecondsDelay
                    $retrycount++
                    $bodySplunk.event.SplunkHECRetry = $retryCount
                }
            }
        }
    } end {return $true}
}
