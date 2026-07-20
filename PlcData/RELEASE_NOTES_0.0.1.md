# PlcData 0.0.1

Initial public release of the PlcData Doosan DART User Command V2 module.

## Highlights

- Adds `Wait IR[B]` for input-register bits 0-63.
- Adds `Wait IR[I]` for input-register INT addresses 0-23.
- Adds `Wait IR[F]` for input-register FLOAT addresses 0-23.
- Supports indefinite waits and decimal timeout values.
- Optional alarm-style timeout popup.
- Clear Task Editor summaries with address/register, desired value, timeout, and `STP` popup indicator.
- English, Dutch, German, Polish, Spanish, Italian, and Korean property-screen translations.
- Polling interval of 100 ms.
- Boolean function result: `True` on a match and `False` on timeout.

## Download

Release asset:

```text
com.zii.plcdata_0.0.1.dm
```

## File verification

SHA-256:

```text
718EC2F569730264BE015C0E95445DFAF23292C61E29C61FE11744668FFC231D
```

File size: `166246` bytes.

## Compatibility

- Package: `com.zii.plcdata`
- SDK version: `6`
- Interface: Doosan Task Editor User Command V2

## Known platform behaviour

- The Task Editor supplies the same generic green hourglass icon for all three commands, even when a module provides individual screen icons.
- User Command names are shortened by the Task Editor. The compact labels are therefore limited to `Wait IR[B]`, `Wait IR[I]`, and `Wait IR[F]`.
- An older package named `com.zwart.wri` may appear as a second `PlcData` group until it is uninstalled.

## Important

The module is not a safety component. Test the register mapping and timeout behaviour in a safe environment before use on a production robot.
