function Write-Lauger {
    <#
    .DESCRIPTION
        This function consumes log information from a script, formats and writes logs to each configured LogStream.
        Use it in place of Write-Warning, Write-Error, etc.
        Write-Lauger will handle writing logs to the host output stream.
    .PARAMETER Message
        The message to log.
    .PARAMETER IsWarning
        Used to log the message as a warning. Will send to LogStreams if Verbosity is Warn or Verbose.
    .PARAMETER IsError
        Used to log the message as an error. Will send to LogStreams if Verbosity is not Quiet.
        Terminates the process if $ErrorAction is not overridden.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Message,
        [switch]$IsError,
        [switch]$IsWarning
    )

    $EnabledLogStreams = $LaugerContext.LogStreams | Where-Object -Property Enabled -eq $true

    foreach ($stream in $EnabledLogStreams) {
        $stream.Summary += "$Message`n"
    }

#     if ($IsError) {
#         Write-Error $Message
#     }
#     $InformationPreference = 'Continue'
#     Write-Information $Message
}
