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
$AugerContext = [pscustomobject]@{
    Application         = $null # required
    Host                = $null
    Source              = $null
    LogFile             = $null
    GUID                = $null
    DefaultVerbosity    = $null
    DefaultLogType      = $null

    LogStreams = New-Object System.Collections.ArrayList
}

New-Variable -Name AugerContext -Value $AugerContext -Scope Script -Force
# ENDREGION
