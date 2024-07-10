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

## [0.2.0] - 2024-07-10

### Added

- Add GUID property to AugerContext. ([`090daec`](https://github.com/terminalPoltergeist/Auger/commit/090daec4f27a895ac823a1daeead78173a283c06))
- Support -Force param for Write-Auger. ([`090daec`](https://github.com/terminalPoltergeist/Auger/commit/090daec4f27a895ac823a1daeead78173a283c06))

### Changed

- Close-AugerSession to filter log types for each log stream's summary before sending. ([`78961d8`](https://github.com/terminalPoltergeist/Auger/commit/78961d8820c3ea6c4079d5ed1e0b2384595ad3b8))
- Send-SlackLog body parameter to support positional parameter. ([`fee8061`](https://github.com/terminalPoltergeist/Auger/commit/fee806130dd787d795e60d1a636c0e47b330d8b6))
- Send-SlackLog to use chunked encoding. ([`b73b953`](https://github.com/terminalPoltergeist/Auger/commit/b73b953110878dbe1807f070cd4915e491494a2f))
- Clear-AugerContext to remove log file. ([`7bc9763`](https://github.com/terminalPoltergeist/Auger/commit/7bc9763ce13e20b385d31bc88ee5c4af35d43587))
- Close-AugerSession to better format summary logs. ([`78961d8`](https://github.com/terminalPoltergeist/Auger/commit/78961d8820c3ea6c4079d5ed1e0b2384595ad3b8),[`9b77fb8`](https://github.com/terminalPoltergeist/Auger/commit/9b77fb8ef9a8180946290f23a07f17242547c781))
- Write-Auger to encode log newlines as \\n characters when appending to the log file. ([`d76c8f6`](https://github.com/terminalPoltergeist/Auger/commit/d76c8f69c4048521f05840908b9d0f2a6e1468b2))

### Fixed

- LogStreams with `Quiet` verbosity should not receive summaries. ([`8d11fdd`](https://github.com/terminalPoltergeist/Auger/commit/8d11fdd1caf3ef18b9bac92d58fdf6ad7c544753))
