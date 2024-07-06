# Auger

*The Powershell logging library designed for automation.*

The benefit of Auger is you can write a single log command, `Write-Auger`, and it will format and forward your logs to a number of configurable log streams, aggregators, and indexers.

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

Auger keeps context data stored in a module scoped variable called $AugerContext.

This variable contains metadata for configuring your logs, as well as an array of objects that are reffered to as LogStreams in Auger.

You can initialize a new AugerContext with the `New-AugerContext` cmdlet. This will populate $AugerContext with some sensible defaults and any configurations you specify with parameters.

You will need to provide an Application to New-AugerContext. This is used to identify the source of your logs in the LogStreams.

The $AugerContext.Host value is configured from the hostname of the system the logging is done from.

The $AugerContext.Source value can be used to differentiate environments or infrastructure your logs are coming from. Think Azure Runbooks, AWS EC2, Ansible, a self-hosted Kubernetes cluster, etc.

The $AugerContext.LogFile stores a System.IO.FileInfo object. This file is created in your system's temp directory and is used by Auger to store an ephemeral summary of your logs.

*Related: [LogStreams](#log-streams)*

## Log Streams

LogStreams are the "destination" for your logs. Auger handles writing logs to the host output streams, but it can also forward logs to a number of places.

Currently, Auger has the ability to forward logs to a Splunk HTTP Event Collector, a Slack channel integration (using webhooks), and an email account through SMTP.

To configure Auger to forward logs, provide the LogStreams required parameters to `New-AugerContext`. See documentation in [New-AugerContext.ps1](./Auger/Public/New-AugerContext.ps1) for more details.
