# Auger

*The Powershell logging library designed for automation.*

<!-- {{{ TOC-->
<details>
<summary>Index</summary>

1. [Getting Started](#getting-started)\
    1a. [Initializing an AugerContext](#initializing-an-augercontext)\
    1b. [Writing Logs](#writing-logs)
2. [AugerContext](#augercontext)
3. [Log Streams](#log-streams)

</details>
<!-- }}} -->

## Getting Started

**Installation**

Auger works with  Powershell 5.1 and the latest version of Powershell 7.

`Install-Module Auger`

### Initializing an AugerContext

An AugerContext is a PSCustomObject that contains necessary metadata for managing logging and log streams.

You initialize an AugerContext with the `New-AugerContext` cmdlet. The only required parameter is Application.

```powershell
Import-Module Auger

New-AugerContext -Application 'Demo'
```

The Application is used to identify the log source in some LogStreams and is used for debug logging.

*Related: [AugerContext](#augercontext)*

### Writing Logs

After configuring an AugerContext, you can simply write logs to Auger and it will format and send them to the configured log streams. 

`Write-Auger 'Initializing the service.'`

This is a regular log in Auger. It will only forward these logs to a log stream if the log stream's verbosity is configured as Verbose.

`Write-Auger 'Careful! This action cannot be undone.' -IsWarning`

This is a warning log in Auger. It will only forward these logs if a log stream's verbosity is configured as Warn or Verbose.

`Write-Auger 'You are unauthorized to access this data.' -IsError`

This is an error log in Auger. It will only forward these logs if a log stream's verbosity is configured as Error, Warn, or Verbose. This is a terminal error and will exit the currently running process.

*Related: [LogStreams](#log-streams)*

## AugerContext

## Log Streams
