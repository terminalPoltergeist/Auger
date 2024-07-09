function Write-Auger {
    <#
    .DESCRIPTION
        This function consumes log information from a script, formats and writes logs to each configured LogStream.
        Use it in place of Write-Warning, Write-Error, etc.
        Write-Auger will handle writing logs to the host output stream.
    .PARAMETER Message
        The message to log.
    .PARAMETER Options
        Support coming soon.
        Parameters to pass to the log stream handler.
        Provided as a hashtable where the key is the parameter name the log stream expects and the value is the value of that parameter.
    .PARAMETER IsWarning
        Used to log the message as a warning. Will send to LogStreams if Verbosity is Warn or Verbose.
    .PARAMETER IsError
        Used to log the message as an error. Will send to LogStreams if Verbosity is not Quiet.
        Terminates the process if $ErrorAction is not overridden.
    .PARAMETER Force
        Will send log to all streams even if LogType is Summary.
    TODO:
    - support advanced message types (pscustomobjects)
      - convert to json string for log streams that expect strings
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Message,
        [hashtable]$Options,
        [switch]$IsError,
        [switch]$IsWarning,
        [switch]$Force
    )

    if ($PSCmdlet.ShouldProcess("$($AugerContext.LogFile.Name)", 'Write to log file')) {
        # when writing to the log file, we need each entry to be on a single line. This joins multi-line logs with \n characters
        $EncodedMessage = $Message.Replace("`n","\n")
        if ($IsError) {
            ("ERROR: {0}" -f $EncodedMessage) | Add-Content -Path $AugerContext.LogFile.FullName
        } elseif ($IsWarning) {
            ("WARN: {0}" -f $EncodedMessage) | Add-Content -Path $AugerContext.LogFile.FullName
        } else {
            ("INFO: {0}" -f $EncodedMessage) | Add-Content -Path $AugerContext.LogFile.FullName
        }
    }

    $EnabledLogStreams = $AugerContext.LogStreams | Where-Object -Property Enabled -eq $true

    foreach ($stream in $EnabledLogStreams) {
        if ($PSCmdlet.ShouldProcess("$($Stream.Name)", "Send log")) {
            if ($stream.LogType -eq 'AdHoc' -or $Force) {
                switch ($stream.Verbosity) {
                'Error' { if ($IsError) {. $stream.Command $Message} }
                'Warn' { if ($IsWarning -or $IsError) {. $stream.Command $Message} }
                'Verbose' { . $stream.Command $Message }
                'Quiet' {continue}
                default {continue}
                }
            }
        }
    }

    if ($IsError) {
        Close-AugerSession
        $ErrorActionPreference = 'Stop'
        Write-Error $Message
    } elseif ($IsWarning) {
        Write-Warning $Message
    } else {
        $InformationPreference = 'Continue'
        Write-Information $Message
    }
}
