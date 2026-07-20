# Changelog

All notable PlcData changes are documented in this file.

## [0.0.1] - 2026-07-20

### Added

- Input Register Bit wait command for registers 0-63 and states `ON`/`OFF`.
- Input Register Int wait command for addresses 0-23 and signed 32-bit values.
- Input Register Float wait command for addresses 0-23 and decimal values.
- Optional positive timeout in seconds.
- Optional alarm-style timeout popup.
- Task Editor summary values and `STP` popup indicator.
- Seven property-screen languages: Dutch, English, German, Polish, Spanish, Italian, and Korean.
- Public user manual, screenshots, and release documentation.

### Technical

- Package name: `com.zii.plcdata`
- DART SDK: `6`
- User Command interface: `USER_COMMAND_V2`
- Polling interval: `0.1` seconds
- Return values: `True` when matched, `False` on timeout

### Distribution

- Module file: `com.zii.plcdata_0.0.1.dm`
- SHA-256: `718EC2F569730264BE015C0E95445DFAF23292C61E29C61FE11744668FFC231D`

[0.0.1]: https://github.com/ZwartIndustrial/Doosan-Modules/releases/tag/plcdata-v0.0.1
