# CHANGELOG

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

- GUID property to AugerContext. ([`090daec`](https://github.com/terminalPoltergeist/Auger/commit/090daec4f27a895ac823a1daeead78173a283c06))

### Changed

- Filter summaries for each log stream's verbosity before sending. ([`78961d8`](https://github.com/terminalPoltergeist/Auger/commit/78961d8820c3ea6c4079d5ed1e0b2384595ad3b8))
- Send-SlackLog body parameter to support positional parameter. ([`fee8061`](https://github.com/terminalPoltergeist/Auger/commit/fee806130dd787d795e60d1a636c0e47b330d8b6))

### Deprecated

### Removed

### Fixed

- LogStreams with `Quiet` verbosity should not receive summaries. ([`8d11fdd`](https://github.com/terminalPoltergeist/Auger/commit/8d11fdd1caf3ef18b9bac92d58fdf6ad7c544753))

### Security
