# REGION source public and private functions
$dotSourceParams = @{
    Filter      = '*.ps1'
    Recurse     = $true
    ErrorAction = 'Continue'
}

$public = @(Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Public/*.ps1') @dotSourceParams )
$private = @(Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Private/*.ps1') @dotSourceParams)

foreach ($import in @($public + $private)) {
    try {
        "Importing $import.Name"
        . $import.FullName
    } catch {
        throw "Unable to source [$($import.FullName)]"
    }
}
# ENDREGION

# REGION module variables
$SentinelContext = [ordered]@{
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

New-Variable -Name SentinelContext -Value $SentinelContext -Scope Script -Force
# ENDREGION
