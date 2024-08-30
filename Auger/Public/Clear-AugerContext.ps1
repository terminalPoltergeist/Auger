function Clear-AugerContext {
    [CmdletBinding()]
    param ()

    if ($Script:AugerContext.LogFile.FullName -and (Test-Path $Script:AugerContext.LogFile.FullName)) {
        Remove-Item $Script:AugerContext.LogFile.FullName
    }

    $Script:AugerContext = [pscustomobject]@{
        Application     = $null
        Host            = $null
        Source          = $null
        LogFile         = $null
        GUID            = $null
        DefaultVerbosity= $null
        DefaultLogType  = $null

        LogStreams = @()
    }
}
