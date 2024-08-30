# CHANGELOG

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

### Changed

### Deprecated

### Removed

### Fixed

### Security

## [0.3.0-alpha.0] - 2024-08-29

### Added

- Global default verbosity and log type values to AugerContext. ([`1ab0907`](https://github.com/terminalPoltergeist/Auger/commit/1ab09075fb7780edf505f33673609e1bbead3abe))
- New-MailStream and Remove-MailStream commands to inialize/delete mail streams. ([`1ab0907`](https://github.com/terminalPoltergeist/Auger/commit/1ab09075fb7780edf505f33673609e1bbead3abe))
- New-SlackStream and Remove-SlackStream commands to inialize/delete slack streams. ([`c5b599e`](https://github.com/terminalPoltergeist/Auger/commit/c5b599ee90e6448438c8a8998bd9b96ef747c5be))
- New-SplunkStream and Remove-SplunkStream commands to inialize/delete splunk streams. ([`c5b599e`](https://github.com/terminalPoltergeist/Auger/commit/c5b599ee90e6448438c8a8998bd9b96ef747c5be))
- Multiple stream support to Send-MailLog, Send-SlackLog, and Send-SplunkLog. ([`c5b599e`](https://github.com/terminalPoltergeist/Auger/commit/c5b599ee90e6448438c8a8998bd9b96ef747c5be))

### Changed

- $AugerContext is no longer initialized with null log streams. ([`1ab0907`](https://github.com/terminalPoltergeist/Auger/commit/1ab09075fb7780edf505f33673609e1bbead3abe),[`c5b599e`](https://github.com/terminalPoltergeist/Auger/commit/c5b599ee90e6448438c8a8998bd9b96ef747c5be))
- Clearing AugerContext no longer uses null log streams. ([`c5b599e`](https://github.com/terminalPoltergeist/Auger/commit/c5b599ee90e6448438c8a8998bd9b96ef747c5be))
- Get-AugerContext returns a copy instead of the object itself. ([`c5b599e`](https://github.com/terminalPoltergeist/Auger/commit/c5b599ee90e6448438c8a8998bd9b96ef747c5be))

### Deprecated

### Removed

### Fixed

- Write-Auger without AugerContext erroring due to log file not existing. ([`c5b599e`](https://github.com/terminalPoltergeist/Auger/commit/c5b599ee90e6448438c8a8998bd9b96ef747c5be))

### Security

## [0.2.0] - 2024-07-10

### Added

- Add GUID property to AugerContext. ([`1d6d3b2`](https://github.com/terminalPoltergeist/Auger/commit/1d6d3b294548f57e2589e333978bbad5e83a1cd3))
- Support -Force param for Write-Auger. ([`1d6d3b2`](https://github.com/terminalPoltergeist/Auger/commit/1d6d3b294548f57e2589e333978bbad5e83a1cd3))

### Changed

- Close-AugerSession to filter log types for each log stream's summary before sending. ([`6f2639f`](https://github.com/terminalPoltergeist/Auger/commit/6f2639f266a98a9b694eed95aa88f7b43d8a5b94))
- Send-SlackLog body parameter to support positional parameter. ([`d7fb07e`](https://github.com/terminalPoltergeist/Auger/commit/d7fb07e67bac333f3f2392ef53b75887f0737b0e))
- Send-SlackLog to use chunked encoding. ([`084a063`](https://github.com/terminalPoltergeist/Auger/commit/084a063d44badea991e32c5f5643403120674ccc))
- Clear-AugerContext to remove log file. ([`4bc9f90`](https://github.com/terminalPoltergeist/Auger/commit/4bc9f904a99d1ad0fd0d2d418db6d730ceacdaf1))
- Close-AugerSession to better format summary logs. ([`6f2639f`](https://github.com/terminalPoltergeist/Auger/commit/6f2639f266a98a9b694eed95aa88f7b43d8a5b94),[`58af33f`](https://github.com/terminalPoltergeist/Auger/commit/58af33fc468391829de66a16ff4da7e0d1caba7b))
- Write-Auger to encode log newlines as \\n characters when appending to the log file. ([`7d6413b`](https://github.com/terminalPoltergeist/Auger/commit/7d6413bf5cba09bc8f3a2b108cc13be55422b99f))

### Fixed

- LogStreams with `Quiet` verbosity should not receive summaries. ([`d4539a4`](https://github.com/terminalPoltergeist/Auger/commit/d4539a4b82cf46b1b24b0a7df5ef1178922762bd))
