function Write-SentinelLog {
    <#
    .DESCRIPTION
        This function consumes log information from a script, formats and writes logs to each configured LogStream.
        Use it in place of Write-Warning, Write-Error, etc.
        Write-SentinelLog will handle writing logs to the host STDOUT stream.
    .PARAMETER Message
        The message to log.
    .PARAMETER IsWarning
        Used to log the message as a warning. Will send to LogStreams if Verbosity is Warn or Verbose.
    .PARAMETER IsError
        Used to log the message as an error. Will send to LogStreams if Verbosity is not Quiet.
        Terminates the process if $ErrorAction is not overridden.
    .PARAMETER SourceType
        Name for the source type the log originates from. Defaults to 'AzureRunbook'
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Message,
        [switch]$IsError,
        [switch]$IsWarning,
        [string]$SourceType = 'AzureRunbook'
    )

    if ($IsError) {
        Write-Error $Message
    }
    $InformationPreference = 'Continue'
    Write-Information $Message
}
